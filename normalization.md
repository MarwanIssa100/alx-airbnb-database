# Database Normalization Analysis for Airbnb Clone

## Current Schema Review

The current database schema consists of 6 main tables:
- `User` - Stores user information
- `Property` - Stores property listings
- `Booking` - Manages reservations
- `Payment` - Handles payment transactions
- `Review` - Stores user reviews
- `Message` - Manages user communications

## Normalization Issues Identified

### 1. First Normal Form (1NF) Violations

**Issue**: The current schema appears to be in 1NF as all attributes contain atomic values and there are no repeating groups.

**Status**: ✅ Compliant with 1NF

### 2. Second Normal Form (2NF) Violations

**Issue**: The current schema appears to be in 2NF as all non-key attributes are fully functionally dependent on their primary keys.

**Status**: ✅ Compliant with 2NF

### 3. Third Normal Form (3NF) Violations

**Issue**: The current schema is mostly in 3NF, but there are some potential improvements for data integrity and efficiency.

**Status**: ⚠️ Mostly compliant, but can be improved

## Recommended Improvements for Better Normalization

### 1. Add Property Amenities Table

**Current Issue**: Property amenities are not explicitly modeled, which could lead to data redundancy if amenities are stored as text in the Property table.

**Solution**: Create a separate `Amenity` table and a junction table `PropertyAmenity`.

```sql
-- AMENITY TABLE
CREATE TABLE Amenity (
    amenity_id CHAR(36) PRIMARY KEY default(uuid()),
    amenity_name VARCHAR(100) NOT NULL UNIQUE,
    amenity_category ENUM('basic', 'luxury', 'safety', 'accessibility') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (amenity_id)
);

-- PROPERTY_AMENITY JUNCTION TABLE
CREATE TABLE PropertyAmenity (
    property_id CHAR(36),
    amenity_id CHAR(36),
    PRIMARY KEY (property_id, amenity_id),
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES Amenity(amenity_id) ON DELETE CASCADE
);
```

### 2. Add Property Type and Category Tables

**Current Issue**: Property types and categories are not standardized, which could lead to inconsistent data entry.

**Solution**: Create separate tables for property types and categories.

```sql
-- PROPERTY_TYPE TABLE
CREATE TABLE PropertyType (
    type_id CHAR(36) PRIMARY KEY default(uuid()),
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (type_id)
);

-- PROPERTY_CATEGORY TABLE
CREATE TABLE PropertyCategory (
    category_id CHAR(36) PRIMARY KEY default(uuid()),
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (category_id)
);
```

### 3. Add Location Standardization

**Current Issue**: The `location` field in the Property table is a simple VARCHAR, which could lead to inconsistent location data.

**Solution**: Create separate tables for countries, states/cities, and neighborhoods.

```sql
-- COUNTRY TABLE
CREATE TABLE Country (
    country_id CHAR(36) PRIMARY KEY default(uuid()),
    country_name VARCHAR(100) NOT NULL UNIQUE,
    country_code CHAR(2) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (country_id)
);

-- STATE TABLE
CREATE TABLE State (
    state_id CHAR(36) PRIMARY KEY default(uuid()),
    country_id CHAR(36),
    state_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (country_id) REFERENCES Country(country_id),
    UNIQUE KEY (country_id, state_name),
    INDEX (state_id)
);

-- CITY TABLE
CREATE TABLE City (
    city_id CHAR(36) PRIMARY KEY default(uuid()),
    state_id CHAR(36),
    city_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (state_id) REFERENCES State(state_id),
    UNIQUE KEY (state_id, city_name),
    INDEX (city_id)
);
```

### 4. Enhanced Property Table

**Updated Property table with better normalization**:

```sql
-- PROPERTY TABLE (UPDATED)
CREATE TABLE Property (
    property_id CHAR(36) PRIMARY KEY default(uuid()),
    host_id CHAR(36),
    type_id CHAR(36),
    category_id CHAR(36),
    city_id CHAR(36),
    p_name VARCHAR(255) NOT NULL,
    p_description TEXT NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    price_per_night DECIMAL(10,2) NOT NULL,
    max_guests INT NOT NULL,
    bedrooms INT NOT NULL,
    bathrooms INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES User(user_id),
    FOREIGN KEY (type_id) REFERENCES PropertyType(type_id),
    FOREIGN KEY (category_id) REFERENCES PropertyCategory(category_id),
    FOREIGN KEY (city_id) REFERENCES City(city_id),
    INDEX (property_id),
    INDEX (host_id),
    INDEX (city_id)
);
```

### 5. Add Payment Status Tracking

**Current Issue**: Payment status is not explicitly tracked.

**Solution**: Add a payment status table.

```sql
-- PAYMENT_STATUS TABLE
CREATE TABLE PaymentStatus (
    status_id CHAR(36) PRIMARY KEY default(uuid()),
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (status_id)
);

-- Updated PAYMENT TABLE
CREATE TABLE Payment (
    payment_id CHAR(36) PRIMARY KEY default(uuid()),
    booking_id CHAR(36),
    status_id CHAR(36),
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    transaction_id VARCHAR(255),
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (status_id) REFERENCES PaymentStatus(status_id),
    INDEX (payment_id)
);
```

## Normalization Benefits

### 1. Data Integrity
- Standardized location data prevents inconsistencies
- Proper foreign key relationships ensure referential integrity
- Enum constraints prevent invalid data entry

### 2. Reduced Redundancy
- Amenities are stored once and referenced by multiple properties
- Location data is normalized to prevent duplication
- Property types and categories are standardized

### 3. Improved Query Performance
- Proper indexing on foreign keys
- Smaller, focused tables allow for better query optimization
- Reduced data duplication means less storage and faster queries

### 4. Scalability
- Easy to add new amenities, property types, or locations
- Flexible structure supports future feature additions
- Better support for internationalization

## Sample Data Insertion

```sql
-- Insert sample data for new tables
INSERT INTO Country (country_name, country_code) VALUES 
('United States', 'US'),
('Canada', 'CA'),
('United Kingdom', 'UK');

INSERT INTO PropertyType (type_name, description) VALUES 
('Apartment', 'Self-contained residential unit'),
('House', 'Detached residential building'),
('Condo', 'Individually owned unit in a shared building'),
('Villa', 'Luxury vacation home');

INSERT INTO Amenity (amenity_name, amenity_category) VALUES 
('WiFi', 'basic'),
('Kitchen', 'basic'),
('Pool', 'luxury'),
('Gym', 'luxury'),
('Wheelchair Accessible', 'accessibility'),
('Smoke Detector', 'safety');
```

## Conclusion

The original schema was already well-designed and mostly compliant with 3NF. The improvements suggested above enhance the database design by:

1. **Eliminating potential data redundancy** through proper normalization
2. **Improving data integrity** with standardized reference tables
3. **Enhancing scalability** for future feature additions
4. **Optimizing query performance** through better table structure

These changes maintain the core functionality while providing a more robust and maintainable database structure suitable for a production Airbnb clone application.
