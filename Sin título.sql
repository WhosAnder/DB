DROP TABLE IF EXISTS ReservaAuto;
DROP TABLE IF EXISTS Reserva;
DROP TABLE IF EXISTS Auto;
DROP TABLE IF EXISTS Cliente;

CREATE TABLE Cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE Auto (
    id_auto SERIAL PRIMARY KEY,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INT NOT NULL,
    placa VARCHAR(20) UNIQUE NOT NULL,
    precio_por_dia NUMERIC(10,2) NOT NULL
);

CREATE TABLE Reserva (
    id_reserva SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE ReservaAuto (
    id_reserva INT NOT NULL,
    id_auto INT NOT NULL,
    PRIMARY KEY (id_reserva, id_auto),
    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
    FOREIGN KEY (id_auto) REFERENCES Auto(id_auto)
);
