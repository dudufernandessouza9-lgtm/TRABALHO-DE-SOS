-- Habilita o suporte a Chaves Estrangeiras no SQLite
PRAGMA foreign_keys = ON;

-- 1. Criar Tabela de Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    telefone TEXT,
    endereco TEXT
);

-- 2. Criar Tabela de Técnicos
CREATE TABLE IF NOT EXISTS tecnicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    especialidade TEXT
);

-- 3. Criar Tabela de Serviços
CREATE TABLE IF NOT EXISTS servicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    preco REAL NOT NULL CHECK(preco >= 0)
);

-- 4. Criar Tabela de Pedidos (Ordens de Serviço)
CREATE TABLE IF NOT EXISTS pedidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    tecnico_id INTEGER NOT NULL,
    data_hora TEXT NOT NULL,
    data_agendamento TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'aberto',
    FOREIGN KEY(cliente_id) REFERENCES clientes(id),
    FOREIGN KEY(tecnico_id) REFERENCES tecnicos(id)
);

-- 5. Criar Tabela de Itens do Pedido
CREATE TABLE IF NOT EXISTS itens_pedido (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pedido_id INTEGER NOT NULL,
    servico_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK(quantidade > 0),
    preco_unitario REAL NOT NULL,
    FOREIGN KEY(pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY(servico_id) REFERENCES servicos(id)
);

-- =========================================================
-- SEED DE DADOS DE DEMONSTRAÇÃO
-- =========================================================

-- Inserção de Clientes Iniciais
INSERT INTO clientes (nome, telefone, endereco) VALUES 
('Matheus Felipe', '41 99123-4567', 'Rua das Flores, 150 - Centro'),
('Ana Júlia Costa', '41 99234-5678', 'Av. Silva Jardim, 1200 - Batel'),
('Carlos Henrique Souza', '41 99345-6789', 'Rua Padre Anchieta, 340 - Bigorrilho'),
('Mariana Alencar', '41 99456-7890', 'Rua XV de Novembro, 890 - Alto da XV'),
('Rodrigo Mendes', '41 99567-8901', 'Rua Brigadeiro Franco, 2100 - Rebouças'),
('Beatriz Santos', '41 99678-9012', 'Av. República Argentina, 145 - Portão'),
('Lucas Oliveira', '41 99789-0123', 'Rua Estados Unidos, 610 - Cabral'),
('Gabriela Rocha', '41 99890-1234', 'Rua Guilherme Pugsley, 85 - Água Verde'),
('Felipe Albuquerque', '41 99901-2345', 'Rua Alferes Poli, 1300 - Centro'),
('Camila Moreira', '41 98812-3456', 'Rua Augusto Stresser, 400 - Hugo Lange'),
('Juliana Fagundes', '41 98723-4567', 'Av. Anita Garibaldi, 1800 - Barreirinha'),
('Bruno Cerqueira', '41 98634-5678', 'Rua Mateus Leme, 950 - São Francisco');

-- Inserção de Técnicos Iniciais
INSERT INTO tecnicos (nome, especialidade) VALUES 
('Jean Carlos', 'Especialista em Higienização de Estofados'),
('Ricardo Souza', 'Supervisor de Limpeza Pós-Obra'),
('Ana Beatriz Lima', 'Técnica em Limpeza Fina e Vidros'),
('Carlos Eduardo', 'Especialista em Tratamento de Pisos');

-- Inserção de Serviços Iniciais
INSERT INTO servicos (nome, preco) VALUES 
('Limpeza Residencial Padrão', 160.00),
('Limpeza Residencial Profunda', 290.00),
('Limpeza Comercial / Escritório', 220.00),
('Limpeza Pós-Obra Premium (m²)', 22.00),
('Higienização de Sofá (3 lug)', 240.00),
('Higienização de Colchão Casal', 180.00),
('Higienização de Tapetes (m²)', 28.00),
('Limpeza de Vidros e Vitrines', 120.00),
('Tratamento e Polimento de Pisos', 350.00),
('Sanitização e Dedetização', 400.00),
('Limpeza de Fachada Predial', 850.00),
('Manutenção de Vidraças Altas', 250.00);
