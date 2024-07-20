-- Tabla de Clientes
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100) NOT NULL
);

-- Tabla de Proyectos
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    proposed_end_date DATE,
    phase VARCHAR(20) CHECK (phase IN ('en preparación', 'iniciado', 'pausado', 'cancelado', 'terminado'))
);

-- Tabla de Tareas
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL REFERENCES projects(id),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    labor_cost DECIMAL(10, 2),
    material_cost DECIMAL(10, 2)
);

-- Tabla de Encargados
CREATE TABLE managers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(50),
    email VARCHAR(100) NOT NULL
);

-- Tabla de Cotizaciones
CREATE TABLE quotations (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL REFERENCES projects(id),
    task_id INT NOT NULL REFERENCES tasks(id),
    quotation_type VARCHAR(20) CHECK (quotation_type IN ('mano de obra', 'material')),
    folio VARCHAR(50) NOT NULL,
    quotation_date DATE NOT NULL,
    general_subtotal DECIMAL(10, 2),
    iva DECIMAL(10, 2),
    other_expenses DECIMAL(10, 2),
    total DECIMAL(10, 2),
    manager_id INT NOT NULL REFERENCES managers(id)
);

-- Tabla de Precios de Mano de Obra
CREATE TABLE labor_prices (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Tabla de Productos
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    unit VARCHAR(20),
    price DECIMAL(10, 2) NOT NULL
);

-- Tabla de Cotizaciones de Mano de Obra
CREATE TABLE labor_quotations (
    id SERIAL PRIMARY KEY,
    quotation_id INT NOT NULL REFERENCES quotations(id),
    labor_price_id INT NOT NULL REFERENCES labor_prices(id)
);

-- Tabla de Cotizaciones de Materiales
CREATE TABLE material_quotations (
    id SERIAL PRIMARY KEY,
    quotation_id INT NOT NULL REFERENCES quotations(id),
    product_id INT NOT NULL REFERENCES products(id)
);

-- Tabla de Desglose de Cotizaciones
CREATE TABLE quotation_breakdown (
    id SERIAL PRIMARY KEY,
    quotation_id INT NOT NULL REFERENCES quotations(id),
    concept VARCHAR(100) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20),
    subtotal DECIMAL(10, 2) NOT NULL
);

CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_projects_client_id ON projects(client_id);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);

ALTER TABLE clients ALTER COLUMN phone SET DEFAULT 'N/A';
ALTER TABLE projects ALTER COLUMN phase SET DEFAULT 'en preparación';
ALTER TABLE quotations ADD CONSTRAINT chk_quotation_type CHECK (quotation_type IN ('mano de obra', 'material'));

INSERT INTO clients (name, address, phone, email)
VALUES 
('Empresa ABC', 'Calle Falsa 123, Ciudad, País', '555-1234', 'contacto@empresaabc.com');

INSERT INTO managers (name, position, email)
VALUES 
('Juan Pérez', 'Gerente de Proyectos', 'juan.perez@empresaabc.com');

INSERT INTO projects (client_id, name, description, start_date, proposed_end_date, phase)
VALUES 
(1, 'Proyecto de Instalación Eléctrica', 'Instalación eléctrica completa para edificio comercial', '2024-07-01', '2024-12-31', 'iniciado');

INSERT INTO tasks (project_id, name, description, labor_cost, material_cost)
VALUES 
(1, 'Instalación de Cableado', 'Instalación de todo el cableado eléctrico', 5000.00, 2000.00),
(1, 'Instalación de Tableros', 'Instalación de tableros eléctricos', 3000.00, 1500.00);

INSERT INTO labor_prices (description, price)
VALUES 
('Electricista', 50.00),
('Ayudante', 30.00);

INSERT INTO products (name, description, unit, price)
VALUES 
('Cable Eléctrico', 'Cable de cobre 10 AWG', 'metro', 1.50),
('Tablero Eléctrico', 'Tablero eléctrico de distribución', 'unidad', 150.00);

INSERT INTO quotations (project_id, task_id, quotation_type, folio, quotation_date, general_subtotal, iva, other_expenses, total, manager_id)
VALUES 
(1, 1, 'mano de obra', 'Q1234', '2024-07-02', 5000.00, 800.00, 200.00, 6000.00, 1),
(1, 1, 'material', 'Q1235', '2024-07-02', 2000.00, 320.00, 80.00, 2400.00, 1);

INSERT INTO labor_quotations (quotation_id, labor_price_id)
VALUES 
(1, 1), -- Electricista para instalación de cableado
(1, 2); -- Ayudante para instalación de cableado

INSERT INTO material_quotations (quotation_id, product_id)
VALUES 
(2, 1); -- Cable eléctrico para instalación de cableado

INSERT INTO quotation_breakdown (quotation_id, concept, quantity, cost, unit, subtotal)
VALUES 
(1, 'Horas de trabajo - Electricista', 100, 50.00, 'hora', 5000.00),
(2, 'Cable Eléctrico', 1000, 1.50, 'metro', 1500.00);

SELECT 
    p.name AS project_name,
    c.name AS client_name,
    t.name AS task_name,
    q.folio,
    q.quotation_date,
    q.quotation_type,
    q.general_subtotal,
    q.iva,
    q.other_expenses,
    q.total,
    m.name AS manager_name
FROM 
    projects p
    JOIN clients c ON p.client_id = c.id
    JOIN tasks t ON t.project_id = p.id
    JOIN quotations q ON q.project_id = p.id AND q.task_id = t.id
    JOIN managers m ON q.manager_id = m.id
WHERE 
    p.id = 1;

