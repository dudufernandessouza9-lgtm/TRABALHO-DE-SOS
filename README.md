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

    # Tabela de serviços
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS servicos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
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
            servico_id INTEGER NOT NULL,
            quantidade INTEGER NOT NULL CHECK(quantidade > 0),
            preco_unitario REAL NOT NULL,
            FOREIGN KEY(pedido_id) REFERENCES pedidos(id),
            FOREIGN KEY(servico_id) REFERENCES servicos(id)
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

# --- CRUD: SERVIÇOS ---
def cadastrar_servico():
    print("\n--- CADASTRO DE SERVIÇO ---")
    nome = ler_texto("Nome do serviço: ")
    preco = ler_preco("Preço R$: ")

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO servicos (nome, preco) VALUES (?,?)",
        (nome, preco)
    )
    conn.commit()
    conn.close()
    print("✅ Serviço cadastrado!\n")

def listar_servicos():
    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("SELECT id, nome, preco FROM servicos ORDER BY nome")
    servicos = cursor.fetchall()
    conn.close()
    return servicos

def exibir_servicos():
    servicos = listar_servicos()
    if not servicos:
        print("⚠️ Nenhum serviço cadastrado.\n")
        return

    print("\n" + "-" * 45)
    print(f"{'ID':<5} | {'NOME DO SERVIÇO':<25} | {'PREÇO':<10}")
    print("-" * 45)
    for id_servico, nome, preco in servicos:
        print(f"{id_servico:<5} | {nome:<25} | R$ {preco:.2f}")
    print("-" * 45 + "\n")

# --- GERENCIAMENTO DE OS ---
def calcular_total_pedido(pedido_id):
    conn = conectar()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT COALESCE(SUM(quantidade * preco_unitario), 0) "
        "FROM itens_pedido WHERE pedido_id=?",
        (pedido_id,)
    )
    total = cursor.fetchone()[0]
    conn.close()
    return float(total)

def registrar_pedido():
    clientes = listar_clientes()
    if not clientes:
        print("⚠️ Cadastre clientes primeiro.\n")
        return

    tecnicos = listar_tecnicos()
    if not tecnicos:
        print("⚠️ Cadastre técnicos primeiro.\n")
        return

    servicos = listar_servicos()
    if not servicos:
        print("⚠️ Cadastre serviços primeiro.\n")
        return

    exibir_clientes()
    cliente_id = ler_inteiro("ID do cliente: ", 1)

    ids_clientes = [cliente[0] for cliente in clientes]
    if cliente_id not in ids_clientes:
        print("⚠️ Cliente não encontrado.\n")
        return

    exibir_tecnicos()
    tecnico_id = ler_inteiro("ID do técnico responsável: ", 1)

    ids_tecnicos = [tecnico[0] for tecnico in tecnicos]
    if tecnico_id not in ids_tecnicos:
        print("⚠️ Técnico não encontrado.\n")
        return

    print("\n--- AGENDAMENTO DA EXECUÇÃO ---")
    data_objeto = ler_data_valida("Digite a data agendada (DD/MM/AAAA): ")
    hora_string = ler_hora_valida("Digite o horário agendado (HH:MM): ")

    data_agendamento = f"{data_objeto.strftime('%Y-%m-%d')} {hora_string}"

    conn = conectar()
    cursor = conn.cursor()

    try:
        # Fuso horário corrigido (-3 horas em relação ao servidor padrão)
        hora_brasilia = datetime.now() - timedelta(hours=3)
        data_abertura = hora_brasilia.strftime("%Y-%m-%d %H:%M:%S")

        cursor.execute(
            "INSERT INTO pedidos (cliente_id, tecnico_id, data_hora, data_agendamento, status) VALUES (?,?,?,?,?)",
            (cliente_id, tecnico_id, data_abertura, data_agendamento, "aberto")
        )
        pedido_id = cursor.lastrowid
        servicos_dict = {servico[0]: servico for servico in servicos}

        print(f"\nOrdem de Serviço #{pedido_id} criada e agendada com sucesso.")
        print("Adicione os serviços executados:")

        while True:
            exibir_servicos()
            entrada = input("ID do serviço (ENTER ou 0 finaliza): ").strip()

            if entrada == "" or entrada == "0":
                break

            if not entrada.isdigit():
                print("⚠️ Digite somente números.\n")
                continue

            servico_id = int(entrada)
            if servico_id not in servicos_dict:
                print("⚠️ Serviço não encontrado.\n")
                continue

            quantidade = ler_inteiro("Quantidade: ", 1)
            preco = servicos_dict[servico_id][2]

            cursor.execute(
                "INSERT INTO itens_pedido (pedido_id, servico_id, quantidade, preco_unitario) VALUES (?,?,?,?)",
                (pedido_id, servico_id, quantidade, preco)
            )
            print("✅ Serviço adicionado.\n")

        cursor.execute(
            "SELECT COUNT(*) FROM itens_pedido WHERE pedido_id=?",
            (pedido_id,)
        )
        quantidade_itens = cursor.fetchone()[0]

        if quantidade_itens == 0:
            cursor.execute("DELETE FROM pedidos WHERE id=?", (pedido_id,))
            conn.commit()
            print("⚠️ OS cancelada por falta de itens.\n")
            return

        conn.commit()
        total = calcular_total_pedido(pedido_id)
        print(f"\n✅ OS #{pedido_id} finalizada com sucesso!")
        print(f"Total: R$ {total:.2f}\n")

    except Exception as erro:
        conn.rollback()
        print("❌ Erro:", erro)

    finally:
        conn.close()

def listar_pedidos():
    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT p.id, c.nome, t.nome, p.data_hora, p.data_agendamento, p.status
        FROM pedidos p
        INNER JOIN clientes c ON c.id = p.cliente_id
        INNER JOIN tecnicos t ON t.id = p.tecnico_id
        ORDER BY p.id DESC
    """)
    pedidos = cursor.fetchall()
    conn.close()
    return pedidos

def exibir_pedidos():
    pedidos = listar_pedidos()
    if not pedidos:
        print("\n⚠️ Nenhuma Ordem de Serviço cadastrada.\n")
        return

    print("\n========== ORDENS DE SERVIÇO (OS) ==========")
    for id_pedido, cliente, tecnico, data, agendamento, status in pedidos:
        total = calcular_total_pedido(id_pedido)
        print(f"""
OS: #{id_pedido}
Cliente: {cliente}
Técnico Responsável: {tecnico}
Data de Abertura: {formatar_data_br(data)}
Agendado para: {formatar_data_sem_segundos_br(agendamento)} ⏰
Status: {status.upper()}
Total: R$ {total:.2f}
--------------------------------------------
""")

def atualizar_status_pedido():
    pedidos = listar_pedidos()
    if not pedidos:
        print("⚠️ Nenhum pedido encontrado.\n")
        return

    exibir_pedidos()
    pedido_id = ler_inteiro("Número da OS: ", 1)

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM pedidos WHERE id=?", (pedido_id,))
    existe = cursor.fetchone()

    if not existe:
        print("⚠️ OS não encontrada.\n")
        conn.close()
        return

    print("\n--- ESCOLHA O STATUS ---")
    for numero, status in enumerate(STATUS_VALIDOS, start=1):
        print(f"{numero} - {status.upper()}")

    while True:
        escolha = input("Novo status (número): ").strip()
        if escolha.isdigit():
            numero = int(escolha)
            if 1 <= numero <= len(STATUS_VALIDOS):
                novo_status = STATUS_VALIDOS[numero - 1]
                break
        print("⚠️ Escolha inválida.\n")

    cursor.execute(
        "UPDATE pedidos SET status=? WHERE id=?",
        (novo_status, pedido_id)
    )
    conn.commit()
    conn.close()
    print("✅ Status alterado com sucesso!\n")

def cadastrar_tecnico():
    print("\n--- CADASTRO DE TÉCNICO ---")
    nome = ler_texto("Nome do Técnico: ")
    especialidade = ler_texto("Especialidade/Cargo (ex: Limpeza Pós-Obra, Dedetização): ")

#  RELATÓRIOS 

#  DETALHES DA OS COM ENDEREÇO DO CLIENTE 
def relatorio_detalhado_pedido():
    conn = conectar()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT p.id, c.nome, p.data_hora
        FROM pedidos p
        INNER JOIN clientes c ON c.id = p.cliente_id
        ORDER BY p.id DESC
    """)
    lista_oss = cursor.fetchall()

    if not lista_oss:
        print("⚠️ Nenhuma OS cadastrada no sistema.\n")
        conn.close()
        return

    print("\n--- ORDENS DE SERVIÇO CADASTRADAS ---")
    print(f"{'ID da OS':<10} | {'Cliente':<25} | {'Data de Abertura':<20}")
    print("-" * 60)
    for id_os, nome_cliente, data_abertura in lista_oss:
        print(f"#{id_os:<9} | {nome_cliente:<25} | {formatar_data_br(data_abertura)}")
    print("-" * 60)

    pedido_id = ler_inteiro("\nDigite o número da OS que deseja detalhar: ", 1)

    cursor.execute("""
        SELECT p.id, c.nome, t.nome, p.data_hora, p.data_agendamento, p.status, c.endereco
        FROM pedidos p
        INNER JOIN clientes c ON c.id=p.cliente_id
        INNER JOIN tecnicos t ON t.id=p.tecnico_id
        WHERE p.id=?
    """, (pedido_id,))
    pedido = cursor.fetchone()

    if not pedido:
        print("⚠️ OS não encontrada.\n")
        conn.close()
        return

    cursor.execute("""
        SELECT s.nome, ip.quantidade, ip.preco_unitario
        FROM itens_pedido ip
        INNER JOIN servicos s ON s.id=ip.servico_id
        WHERE ip.pedido_id=?
    """, (pedido_id,))
    itens = cursor.fetchall()
    conn.close()

    # Formata a exibição do endereço
    endereco_exibicao = pedido[6] if pedido[6] else "Não informado"

    print("\n" + "=" * 45)
    print(f" OS DETALHADA: #{pedido[0]}")
    print("=" * 45)
    print(f"Cliente: {pedido[1]}")
    print(f"Técnico Responsável: {pedido[2]}")
    print(f"Abertura do Chamado: {formatar_data_br(pedido[3])}")
    print(f"Execução Agendada: {formatar_data_sem_segundos_br(pedido[4])} ⏰")
    print(f"Endereço do Serviço: {endereco_exibicao} 📍")
    print(f"Status: {pedido[5].upper()}")
    print("-" * 45)

    print("Serviços Executados:")
    for nome, quantidade, preco in itens:
        print(f" • {quantidade}x {nome} = R$ {quantidade * preco:.2f}")

    total = calcular_total_pedido(pedido_id)
    print("-" * 45)
    print(f"TOTAL DA OS: R$ {total:.2f}")
    print("=" * 45 + "\n")

def relatorio_por_cliente():
    clientes = listar_clientes()
    if not clientes:
        print("Nenhum cliente cadastrado.\n")
        return

    exibir_clientes()
    cliente_id = ler_inteiro("ID do cliente: ", 1)

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT p.id, t.nome, p.data_hora, p.data_agendamento, p.status
        FROM pedidos p
        INNER JOIN tecnicos t ON t.id=p.tecnico_id
        WHERE p.cliente_id=? ORDER BY p.id DESC
    """, (cliente_id,))
    pedidos = cursor.fetchall()
    conn.close()

    if not pedidos:
        print("Nenhuma OS encontrada para este cliente.\n")
        return

    total_cliente = 0
    print("\n--- HISTÓRICO DE OS POR CLIENTE ---")
    for id_pedido, tecnico, data, agendamento, status in pedidos:
        total = calcular_total_pedido(id_pedido)
        total_cliente += total
        print(f"OS: #{id_pedido} | Responsável: {tecnico} | Abertura: {formatar_data_br(data)} | Agendado: {formatar_data_sem_segundos_br(agendamento)} | Status: {status.upper()} | R$ {total:.2f}")

    print(f"\nTotal investido pelo cliente: R$ {total_cliente:.2f}\n")

def relatorio_por_periodo():
    print("\n--- FILTRAR POR PERÍODO ---")
    dt_inicio = ler_data_valida("Data inicial (DD/MM/AAAA): ")
    dt_fim = ler_data_valida("Data final (DD/MM/AAAA): ")

    inicio = dt_inicio.strftime("%Y-%m-%d")
    fim = dt_fim.strftime("%Y-%m-%d")

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT p.id, c.nome, t.nome, p.data_hora, p.data_agendamento, p.status
        FROM pedidos p
        INNER JOIN clientes c ON c.id=p.cliente_id
        INNER JOIN tecnicos t ON t.id=p.tecnico_id
        WHERE date(p.data_hora) BETWEEN ? AND ?
        ORDER BY p.data_hora
    """, (inicio, fim))
    pedidos = cursor.fetchall()
    conn.close()

    if not pedidos:
        print("\n⚠️ Nenhuma OS encontrada nesse período.\n")
        return

    total_periodo = 0
    print("\n========== RELATÓRIO DE OS POR PERÍODO ==========")
    for id_pedido, nome_cliente, nome_tecnico, data, agendamento, status in pedidos:
        total = calcular_total_pedido(id_pedido)
        total_periodo += total
        print(f"OS: #{id_pedido} | Cliente: {nome_cliente} | Técnico: {nome_tecnico} | Abertura: {formatar_data_br(data)} | Agendamento: {formatar_data_sem_segundos_br(agendamento)} | Status: {status.upper()} | Total: R$ {total:.2f}")

    print(f"\nTOTAL FATURADO NO PERÍODO: R$ {total_periodo:.2f}\n")

def relatorio_por_status():
    print("\n--- FILTRAR POR STATUS ---")
    print("1 - Abertas / Pendentes")
    print("2 - Em Andamento")
    print("3 - Concluídas / Realizadas")
    print("4 - Canceladas")

    opcao = escolher_opcao("Escolha uma opção (1-4): ", ["1", "2", "3", "4"])
    status_map = {"1": "aberto", "2": "em andamento", "3": "concluido", "4": "cancelado"}
    status_buscado = status_map[opcao]

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT p.id, c.nome, t.nome, p.data_hora, p.data_agendamento
        FROM pedidos p
        INNER JOIN clientes c ON c.id=p.cliente_id
        INNER JOIN tecnicos t ON t.id=p.tecnico_id
        WHERE p.status=?
        ORDER BY p.id DESC
    """, (status_buscado,))
    pedidos = cursor.fetchall()
    conn.close()

    if not pedidos:
        print(f"\n⚠️ Nenhuma OS encontrada com o status '{status_buscado}'.\n")
        return

    print(f"\n========== RELATÓRIO DE ORDENS DE SERVIÇO: {status_buscado.upper()} ==========")
    total_acumulado = 0
    for id_pedido, cliente, tecnico, data, agendamento in pedidos:
        total = calcular_total_pedido(id_pedido)
        total_acumulado += total
        print(f"OS: #{id_pedido} | Cliente: {cliente} | Técnico: {tecnico} | Abertura: {formatar_data_br(data)} | Agendado: {formatar_data_sem_segundos_br(agendamento)} | Valor: R$ {total:.2f}")

    print(f"\nValor total neste status: R$ {total_acumulado:.2f}\n")

#  MENU PRINCIPAL 
def menu():
    criar_tabelas()

    opcoes = {
        "1": cadastrar_cliente,
        "2": exibir_clientes,
        "3": cadastrar_tecnico,
        "4": exibir_tecnicos,
        "5": cadastrar_servico,
        "6": exibir_servicos,
        "7": registrar_pedido,
        "8": exibir_pedidos,
        "9": atualizar_status_pedido,
        "10": relatorio_detalhado_pedido,
        "11": relatorio_por_cliente,
        "12": relatorio_por_periodo,
        "13": relatorio_por_status
    }

    while True:
        print("\n" + "=" * 55)
        print(" SISTEMA DE CONTROLE DE ORDENS DE SERVIÇO")
        print(" EMPRESA DE LIMPEZA E MANUTENÇÃO")
        print("=" * 55)

        print("""
1  - Cadastrar cliente
2  - Listar clientes
3  - Cadastrar técnico
4  - Listar técnicos
5  - Cadastrar serviço
6  - Listar serviços
7  - Registrar e Agendar OS
8  - Listar OSs
9  - Alterar status da OS
10 - Detalhes de uma OS Específica
11 - Relatório por cliente
12 - Relatório por período
13 - Relatório de Serviços Realizados / Pendentes
0  - Sair
""")

        opcao = input("Escolha uma opção: ").strip()

        if opcao == "0":
            print("\nSistema encerrado.")
            break

        if opcao in opcoes:
            try:
                opcoes[opcao]()
            except Exception as erro:
                print("❌ Erro inesperado:", erro)
        else:
            print("⚠️ Opção inválida.\n")

if __name__ == "__main__":
    menu()


