import os

from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, text 
# Importa a classe URL do SQLAlchemy para construir a URL de conexão   
from sqlalchemy.engine import URL

# Identifica o diretório raiz do projeto
BASE_DIR = Path(__file__).resolve().parent.parent

# Define o caminho para o arquivo .env
ENV_PATH = BASE_DIR / '.env'

# Carrega as variáveis de ambiente do arquivo .env
load_dotenv(dotenv_path=ENV_PATH)

# Recupera as configurações de conexão com o PostgreSQL
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# Organiza as configurações obrigatórias
config = {
    "DB_HOST": DB_HOST,
    "DB_PORT": DB_PORT,
    "DB_NAME": DB_NAME,
    "DB_USER": DB_USER,
    "DB_PASSWORD": DB_PASSWORD,
}

# Identifica variáveis ausentes ou vazias
variaveis_ausentes = [
    nome for nome, valor in config.items() if not valor
]

if variaveis_ausentes:
    raise ValueError(
        "Variáveis de ambiente ausentes: "
        + ", ".join(variaveis_ausentes)
    )

# Constrói a URL de conexão com PostgreSQL
DATABASE_URL = URL.create(
    drivername="postgresql+psycopg",
    username=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=int(DB_PORT),
    database=DB_NAME,
)

# Cria o Engine de conexão com PostgreSQL
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True
)

# Testa a conexão com o PostgreSQL
if __name__ == "__main__":
    with engine.connect() as conexao:
        resultado = conexao.execute(text("SELECT 1"))
        print("Resultado do teste:", resultado.scalar())