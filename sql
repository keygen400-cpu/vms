CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin','operator') DEFAULT 'operator',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO users (username, password_hash, role) VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'); -- pass: admin

CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(50) PRIMARY KEY, barcode VARCHAR(100) UNIQUE NOT NULL, name VARCHAR(255) NOT NULL,
    sku VARCHAR(100), is_draft TINYINT(1) DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, INDEX idx_barcode (barcode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS receiving_batches (
    id VARCHAR(50) PRIMARY KEY, batch_number VARCHAR(50) UNIQUE NOT NULL, status ENUM('draft','active','completed') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, completed_at TIMESTAMP NULL, created_by VARCHAR(50),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS receiving_items (
    id INT AUTO_INCREMENT PRIMARY KEY, batch_id VARCHAR(50) NOT NULL, product_id VARCHAR(50) NOT NULL,
    quantity INT DEFAULT 1, last_scanned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_batch_product (batch_id, product_id), FOREIGN KEY (batch_id) REFERENCES receiving_batches(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS locations (
    id VARCHAR(50) PRIMARY KEY, code VARCHAR(50) UNIQUE NOT NULL, name VARCHAR(255) NOT NULL,
    type ENUM('zone','shelf','cell') DEFAULT 'shelf', parent_id VARCHAR(50) NULL, FOREIGN KEY (parent_id) REFERENCES locations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS inventory (
    id INT AUTO_INCREMENT PRIMARY KEY, product_id VARCHAR(50) NOT NULL, location_id VARCHAR(50) NOT NULL,
    quantity INT DEFAULT 0, reserved INT DEFAULT 0, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_prod_loc (product_id, location_id), FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS movements (
    id INT AUTO_INCREMENT PRIMARY KEY, product_id VARCHAR(50) NOT NULL, from_location_id VARCHAR(50) NULL,
    to_location_id VARCHAR(50) NULL, quantity INT NOT NULL, movement_type ENUM('receive','move','ship','adjust') NOT NULL,
    batch_id VARCHAR(50) NULL, created_by VARCHAR(50), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id), FOREIGN KEY (from_location_id) REFERENCES locations(id),
    FOREIGN KEY (to_location_id) REFERENCES locations(id), FOREIGN KEY (batch_id) REFERENCES receiving_batches(id), INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
