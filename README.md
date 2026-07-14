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

    # --- CARGA INICIAL DE DADOS DE DEMONSTRAÇÃO (SEED) ---
    
    # 1. Popula Clientes (12 Pessoas Físicas)
    cursor.execute("SELECT COUNT(*) FROM clientes")
    if cursor.fetchone()[0] == 0:
        clientes_demo = [
            ("Matheus Felipe", "41 99123-4567", "Rua das Flores, 150 - Centro"),
            ("Ana Júlia Costa", "41 99234-5678", "Av. Silva Jardim, 1200 - Batel"),
            ("Carlos Henrique Souza", "41 99345-6789", "Rua Padre Anchieta, 340 - Bigorrilho"),
            ("Mariana Alencar", "41 99456-7890", "Rua XV de Novembro, 890 - Alto da XV"),
            ("Rodrigo Mendes", "41 99567-8901", "Rua Brigadeiro Franco, 2100 - Rebouças"),
            ("Beatriz Santos", "41 99678-9012", "Av. República Argentina, 145 - Portão"),
            ("Lucas Oliveira", "41 99789-0123", "Rua Estados Unidos, 610 - Cabral"),
            ("Gabriela Rocha", "41 99890-1234", "Rua Guilherme Pugsley, 85 - Água Verde"),
            ("Felipe Albuquerque", "41 99901-2345", "Rua Alferes Poli, 1300 - Centro"),
            ("Camila Moreira", "41 98812-3456", "Rua Augusto Stresser, 400 - Hugo Lange"),
            ("Juliana Fagundes", "41 98723-4567", "Av. Anita Garibaldi, 1800 - Barreirinha"),
            ("Bruno Cerqueira", "41 98634-5678", "Rua Mateus Leme, 950 - São Francisco")
        ]
        cursor.executemany("INSERT INTO clientes (nome, telefone, endereco) VALUES (?,?,?)", clientes_demo)

    # 2. Popula Técnicos (4 profissionais)
    cursor.execute("SELECT COUNT(*) FROM tecnicos")
    if cursor.fetchone()[0] == 0:
        tecnicos_demo = [
            ("Jean Carlos", "Especialista em Higienização de Estofados"),
            ("Ricardo Souza", "Supervisor de Limpeza Pós-Obra"),
            ("Ana Beatriz Lima", "Técnica em Limpeza Fina e Vidros"),
            ("Carlos Eduardo", "Especialista em Tratamento de Pisos")
        ]
        cursor.executemany("INSERT INTO tecnicos (nome, especialidade) VALUES (?,?)", tecnicos_demo)

    # 3. Popula Produtos e Serviços (10 itens)
    cursor.execute("SELECT COUNT(*) FROM produtos")
    if cursor.fetchone()[0] == 0:
        produtos_demo = [
            ("Limpeza Residencial Comum", "servico", 150.00),
            ("Limpeza Residencial Profunda", "servico", 280.00),
            ("Higienização de Sofá (3 lug)", "servico", 220.00),
            ("Higienização de Tapete (m²)", "servico", 25.00),
            ("Limpeza Pós-Obra (m²)", "servico", 18.00),
            ("Limpeza de Vidros/Janelas", "servico", 90.00),
            ("Detergente Neutro Concentrado", "produto", 15.90),
            ("Desinfetante Perfumado 5L", "produto", 32.50),
            ("Impermeabilizante de Tecidos", "produto", 85.00),
            ("Cera Auto-Brilho para Pisos", "produto", 49.90)
        ]
        cursor.executemany("INSERT INTO produtos (nome, tipo, preco) VALUES (?,?,?)", produtos_demo)

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
    try:
        dt = datetime.strptime(data_banco, "%Y-%m-%d %H:%M:%S")
        return dt.strftime("%d/%m/%Y %H:%M:%S")
    except ValueError:
        return data_banco

def formatar_data_sem_segundos_br(data_banco):
    try:
        dt = datetime.strptime(data_banco, "%Y-%m-%d %H:%M:%S")
        return dt.strftime("%d/%m/%Y %H:%M")
    except ValueError:
        return data_banco

# --- CRUD: CLIENTES ---
def cadastrar_cliente():
    print("\n--- CADASTRO DE CLIENTE ---")
    nome = ler_texto("Nome: ")
    telefone = ler_texto("Telefone (opcional): ", False)
    endereco = ler_texto("Endereço / Local de Atendimento (opcional): ", False)

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO clientes (nome, telefone, endereco) VALUES (?,?,?)",
        (nome, telefone, endereco)
    )
    conn.commit()
    conn.close()
    print("✅ Cliente cadastrado com sucesso!\n")

# --- NOVO: ALTERAR CLIENTE (E SEU LOCAL AGENDADO) ---
def alterar_cliente():
    print("\n--- ALTERAR DADOS DO CLIENTE ---")
    exibir_clientes()
    cliente_id = ler_inteiro("Digite o ID do cliente que deseja alterar: ", 1)

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("SELECT nome, telefone, endereco FROM clientes WHERE id=?", (cliente_id,))
    cliente = cursor.fetchone()

    if not cliente:
        print("⚠️ Cliente não encontrado.\n")
        conn.close()
        return

    print(f"\nDados atuais -> Nome: {cliente[0]} | Tel: {cliente[1]} | Local: {cliente[2]}")
    print("(Pressione ENTER sem digitar nada para manter o dado atual)")
    
    novo_nome = input(f"Novo Nome [{cliente[0]}]: ").strip()
    novo_nome = novo_nome if novo_nome != "" else cliente[0]

    novo_tel = input(f"Novo Telefone [{cliente[1]}]: ").strip()
    novo_tel = novo_tel if novo_tel != "" else cliente[1]

    novo_end = input(f"Novo Local de Atendimento [{cliente[2]}]: ").strip()
    novo_end = novo_end if novo_end != "" else cliente[2]

    cursor.execute("""
        UPDATE clientes 
        SET nome=?, telefone=?, endereco=? 
        WHERE id=?
    """, (novo_nome, novo_tel, novo_end, cliente_id))
    
    conn.commit()
    conn.close()
    print("✅ Dados do cliente atualizados com sucesso!\n")

# --- NOVO: EXCLUIR CLIENTE ---
def excluir_cliente():
    print("\n--- EXCLUIR CLIENTE ---")
    exibir_clientes()
    cliente_id = ler_inteiro("Digite o ID do cliente que deseja EXCLUIR: ", 1)

    conn = conectar()
    cursor = conn.cursor()
    
    try:
        cursor.execute("DELETE FROM clientes WHERE id=?", (cliente_id,))
        conn.commit()
        print("✅ Cliente excluído com sucesso!\n")
    except sqlite3.IntegrityError:
        print("❌ Erro: Não é possível excluir um cliente que possui Ordens de Serviço vinculadas a ele!")
    finally:
        conn.close()

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
