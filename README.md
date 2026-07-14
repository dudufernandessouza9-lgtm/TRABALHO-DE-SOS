import sqlite3
from datetime import datetime, timedelta

NOME_BANCO = "pedidos_limpeza.db"
STATUS_VALIDOS = ["aberto", "em andamento", "concluido", "cancelado"]

def conectar():
    conn = sqlite3.connect(NOME_BANCO)
    conn.execute("PRAGMA foreign_keys = ON")
    return conn

def criar_tabelas():
    conn = conectar()
    cursor = conn.cursor()

    # Tabela clientes
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            telefone TEXT,
            endereco TEXT
        )
    """)

    # Tabela tecnicos
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tecnicos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            especialidade TEXT
        )
    """)

    # Tabela produtos/serviços
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            tipo TEXT NOT NULL CHECK(tipo IN ('produto','servico')),
            preco REAL NOT NULL CHECK(preco >= 0)
        )
    """)

    # Tabela pedidos (Ordens de Serviço)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pedidos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            tecnico_id INTEGER NOT NULL,
            data_hora TEXT NOT NULL,            -- Data de Abertura (Automática)
            data_agendamento TEXT NOT NULL,     -- Data/Hora do Agendamento (Manual)
            status TEXT NOT NULL DEFAULT 'aberto',
            FOREIGN KEY(cliente_id) REFERENCES clientes(id),
            FOREIGN KEY(tecnico_id) REFERENCES tecnicos(id)
        )
    """)

    # Tabela de itens no pedido
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS itens_pedido (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pedido_id INTEGER NOT NULL,
            produto_id INTEGER NOT NULL,
            quantidade INTEGER NOT NULL CHECK(quantidade > 0),
            preco_unitario REAL NOT NULL,
            FOREIGN KEY(pedido_id) REFERENCES pedidos(id),
            FOREIGN KEY(produto_id) REFERENCES produtos(id)
        )
    """)

    conn.commit()
    conn.close()

def ler_texto(mensagem, obrigatorio=True):
    while True:
        valor = input(mensagem).strip()
        if obrigatorio and valor == "":
            print("⚠️ Campo obrigatório.")
            continue
        return valor

def ler_inteiro(mensagem, minimo=None):
    while True:
        valor = input(mensagem).strip()
        if not valor.isdigit():
            print("⚠️ Digite somente números.")
            continue
        numero = int(valor)
        if minimo is not None and numero < minimo:
            print(f"⚠️ Digite valor maior ou igual a {minimo}.")
            continue
        return numero

def ler_preco(mensagem):
    while True:
        valor = input(mensagem).replace(",", ".").strip()
        try:
            preco = float(valor)
            if preco < 0:
                raise ValueError
            return preco
        except ValueError:
            print("⚠️ Preço inválido.")

def escolher_opcao(mensagem, lista):
    while True:
        valor = input(mensagem).strip().lower()
        if valor in lista:
            return valor
        print("⚠️ Opção inválida.")

def ler_data_valida(mensagem):
    while True:
        data_str = ler_texto(mensagem)
        try:
            data_valida = datetime.strptime(data_str, "%d/%m/%Y")
            return data_valida
        except ValueError:
            print("⚠️ Data inválida ou inexistente. Use o formato DD/MM/AAAA (ex: 13/07/2026).")

def ler_hora_valida(mensagem):
    while True:
        hora_str = ler_texto(mensagem)
        try:
            hora_valida = datetime.strptime(hora_str, "%H:%M")
            return hora_valida.strftime("%H:%M:%S")
        except ValueError:
            print("⚠️ Horário inválido ou inexistente. Use o formato de 24h HH:MM (ex: 14:30).")

def formatar_data_br(data_banco):
    """Converte a data de AAAA-MM-DD HH:MM:SS para DD/MM/AAAA HH:MM:SS"""
    try:
        dt = datetime.strptime(data_banco, "%Y-%m-%d %H:%M:%S")
        return dt.strftime("%d/%m/%Y %H:%M:%S")
    except ValueError:
        return data_banco

def formatar_data_sem_segundos_br(data_banco):
    """Converte a data de AAAA-MM-DD HH:MM:SS para DD/MM/AAAA HH:MM"""
    try:
        dt = datetime.strptime(data_banco, "%Y-%m-%d %H:%M:%S")
        return dt.strftime("%d/%m/%Y %H:%M")
    except ValueError:
        return data_banco

# --- CRUD: CLIENTES ---
def cadastrar_cliente():
    print("\n--- CADASTRO DE CLIENTE ---")
    nome = ler_texto("Nome: ")
    telefone = ler_texto("Telefone: ", False)
    endereco = ler_texto("Endereço,: ", False)

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO clientes (nome, telefone, endereco) VALUES (?,?,?)",
        (nome, telefone, endereco)
    )
    conn.commit()
    conn.close()
    print("✅ Cliente cadastrado com sucesso!\n")

def listar_clientes():
    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("SELECT id, nome, telefone FROM clientes ORDER BY nome")
    clientes = cursor.fetchall()
    conn.close()
    return clientes

def exibir_clientes():
    clientes = listar_clientes()
    if not clientes:
        print("⚠️ Nenhum cliente cadastrado.\n")
        return

    print("\n" + "-" * 50)
    print(f"{'ID':<5} | {'NOME':<25} | {'TELEFONE':<15}")
    print("-" * 50)
    for id_cliente, nome, telefone in clientes:
        tel = telefone if telefone else "-"
        print(f"{id_cliente:<5} | {nome:<25} | {tel:<15}")
    print("-" * 50 + "\n")

# --- CRUD: TÉCNICOS ---
def cadastrar_tecnico():
    print("\n--- CADASTRO DE TÉCNICO ---")
    nome = ler_texto("Nome do Técnico: ")
    especialidade = ler_texto("Especialidade/Cargo (ex: Limpeza Pós-Obra, Dedetização): ")

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO tecnicos (nome, especialidade) VALUES (?,?)",
        (nome, especialidade)
    )
    conn.commit()
    conn.close()
    print("✅ Técnico cadastrado com sucesso!\n")

def listar_tecnicos():
    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("SELECT id, nome, especialidade FROM tecnicos ORDER BY nome")
    tecnicos = cursor.fetchall()
    conn.close()
    return tecnicos

def exibir_tecnicos():
    tecnicos = listar_tecnicos()
    if not tecnicos:
        print("⚠️ Nenhum técnico cadastrado.\n")
        return

    print("\n" + "-" * 60)
    print(f"{'ID':<5} | {'NOME DO TÉCNICO':<25} | {'ESPECIALIDADE':<25}")
    print("-" * 60)
    for id_tecnico, nome, especialidade in tecnicos:
        print(f"{id_tecnico:<5} | {nome:<25} | {especialidade:<25}")
    print("-" * 60 + "\n")

# --- CRUD: PRODUTOS / SERVIÇOS ---
def cadastrar_produto():
    print("\n--- CADASTRO DE PRODUTO/SERVIÇO ---")
    nome = ler_texto("Nome do produto/serviço: ")
    tipo = escolher_opcao("Tipo (produto/servico): ", ["produto", "servico"])
    preco = ler_preco("Preço R$: ")

    conn = conectar()
