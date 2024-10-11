from quart import Quart, jsonify
import aiohttp
import asyncio
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials, firestore

# Inicializar o Firebase Admin SDK com as credenciais
cred = credentials.Certificate(r"C:\Users\augus\Downloads\glicometrics-firebase-adminsdk-wjp0l-7f2f33e94e.json")
firebase_admin.initialize_app(cred)

# Conectar ao Firestore
db = firestore.client()

app = Quart(__name__)

# Todas as páginas relevantes para coleta de dados (A-Z)
TODAS_AS_PAGINAS = list(range(1, 58))  # Páginas de 1 a 57

# Função para buscar uma página
async def fetch_page(session, url):
    try:
        async with session.get(url) as response:
            return await response.text()
    except Exception as e:
        print(f"Erro ao buscar {url}: {e}")
        return None

# Função para extrair detalhes nutricionais do alimento
async def fetch_detalhes_alimento(session, codigo):
    url = f'https://www.tbca.net.br/base-dados/int_composicao_alimentos.php?cod_produto={codigo}'
    response_text = await fetch_page(session, url)

    if not response_text:
        return None

    soup = BeautifulSoup(response_text, 'html.parser')
    tabela_nutrientes = soup.find('table')
    if not tabela_nutrientes:
        return None

    # Extrair os dados necessários da tabela de nutrientes
    nutrientes = {
        'energia': 'N/A',
        'proteina': 'N/A',
        'lipidios': 'N/A',
        'carboidrato_total': 'N/A'
    }

    for row in tabela_nutrientes.find_all('tr'):
        cols = row.find_all('td')
        if len(cols) > 1:
            componente = cols[0].text.strip().lower()
            valor_por_100g = cols[2].text.strip()

            if 'energia' in componente and 'kcal' in cols[1].text:
                nutrientes['energia'] = valor_por_100g
            elif 'proteína' in componente:
                nutrientes['proteina'] = valor_por_100g
            elif 'lipídios' in componente:
                nutrientes['lipidios'] = valor_por_100g
            elif 'carboidrato total' in componente:
                nutrientes['carboidrato_total'] = valor_por_100g

    return nutrientes

# Função para buscar todos os alimentos de todas as páginas
async def fetch_todos_os_alimentos():
    base_url = 'https://www.tbca.net.br/base-dados/composicao_estatistica.php'
    alimentos = []

    async with aiohttp.ClientSession() as session:
        tasks = []

        # Loop pelas páginas relevantes (1 a 57)
        for pagina in TODAS_AS_PAGINAS:
            url = f'{base_url}?pagina={pagina}&atuald=1'
            tasks.append(fetch_page(session, url))

        # Executa as tarefas em paralelo
        pages = await asyncio.gather(*tasks)

        # Processa as páginas após todas terem sido baixadas
        for page in pages:
            if page is None:
                continue  # Ignora páginas que não foram baixadas

            soup = BeautifulSoup(page, 'html.parser')
            table = soup.find('table')

            if not table:
                continue

            # Itera pelas linhas da tabela
            for row in table.find_all('tr')[1:]:
                cols = row.find_all('td')
                if len(cols) > 0:
                    codigo = cols[0].text.strip()
                    nome = cols[1].text.strip()

                    # Buscar detalhes nutricionais do alimento
                    detalhes_nutricionais = await fetch_detalhes_alimento(session, codigo)

                    # Adicionar o alimento à lista com detalhes
                    alimentos.append({
                        'codigo': codigo,
                        'nome': nome,
                        'energia': detalhes_nutricionais.get('energia', 'N/A'),
                        'proteina': detalhes_nutricionais.get('proteina', 'N/A'),
                        'lipidios': detalhes_nutricionais.get('lipidios', 'N/A'),
                        'carboidrato_total': detalhes_nutricionais.get('carboidrato_total', 'N/A')
                    })

    return alimentos

# Função para enviar todos os alimentos de uma vez para o Firebase
def enviar_todos_para_firebase(alimentos):
    batch = db.batch()  # Usar uma operação em lote (batch) para enviar todos os dados juntos

    for alimento in alimentos:
        doc_ref = db.collection("alimentos").document(alimento['codigo'])  # Documento com o código como ID
        batch.set(doc_ref, {
            'codigo': alimento['codigo'],
            'nome': alimento['nome'],
            'energia': alimento['energia'],
            'proteina': alimento['proteina'],
            'lipidios': alimento['lipidios'],
            'carboidrato_total': alimento['carboidrato_total']
        })
    
    batch.commit()  # Executa todas as operações de uma vez
    print(f"Enviados {len(alimentos)} alimentos para o Firebase.")

# Endpoint da API para buscar todos os alimentos e enviá-los ao Firebase
@app.route('/api/enviar_alimentos', methods=['POST'])
async def enviar_alimentos():
    alimentos = await fetch_todos_os_alimentos()

    # Enviar todos os alimentos para o Firebase
    enviar_todos_para_firebase(alimentos)

    return jsonify({"message": f"{len(alimentos)} alimentos enviados para o Firebase com sucesso."})

# Iniciar o servidor
if __name__ == '__main__':
    app.run(debug=True)
