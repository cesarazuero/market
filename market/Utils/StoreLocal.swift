//
//  StoreLocal.swift
//  market
//
//  Created by Cesar Julián Azuero Garavito on 9/24/19.
//  Copyright © 2019 Prueba. All rights reserved.
//

import Foundation
import SQLite3

class StoreLocal
{
    let dbURL: URL
    // The database pointer.
    var db: OpaquePointer?
    var insertEntryStmt: OpaquePointer?
    var readEntryStmt: OpaquePointer?
    var updateEntryStmt: OpaquePointer?
    var deleteEntryStmt: OpaquePointer?
    
    init()
    {
        do
        {
            do
            {
                dbURL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent("market.db")
                print("URL: %s", dbURL.absoluteString)
            }
            catch {
                //TODO: Just logging the error and returning empty path URL here. Handle the error gracefully after logging
                print("Some error occurred. Returning empty path.")
                dbURL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTables()
        }
        catch {
            //TODO: Handle the error gracefully after logging
            print("Some error occurred. Returning.")
            return
        }
    }
    
    // Command: sqlite3_open(dbURL.path, &db)
    // Open the DB at the given path. If file does not exists, it will create one for you
    func openDB() throws
    {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK
        {
            throw SqliteError(message: "error opening database \(dbURL.absoluteString)")
        }
    }
    
    // Code to delete a db file. Useful to invoke in case of a corrupt DB and re-create another
    func deleteDB(dbURL: URL)
    {
        do
        {
            try FileManager.default.removeItem(at: dbURL)
        } catch {
            print("exception while removing db \(error.localizedDescription)")
        }
    }
    
    func createTables() throws
    {
        // create the tables if they dont exist.
        
        // create the table to store the entries.
        // ID | Name | Employee Id | Designation
        let ret =  sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Compras (id INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT, id_producto TEXT NOT NULL, nombre TEXT NOT NULL, precio TEXT NOT NULL, ruta_imagen TEXT NOT NULL)", nil, nil, nil)
        if (ret != SQLITE_OK) { // corrupt database.
            logDbErr("Error creating db table - Compras")
            throw SqliteError(message: "unable to create table Carrito")
        }
    }
    
    func prepareInsertEntryStmt() -> Int32
    {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        let sql = "INSERT INTO Compras (id_producto, nombre, precio, ruta_imagen) VALUES (?,?,?,?)";
        
        let r = sqlite3_prepare(db, sql, -1, &insertEntryStmt, nil)
        if  r != SQLITE_OK
        {
            logDbErr("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    func prepareReadEntryStmt() -> Int32
    {
        guard readEntryStmt == nil else { return SQLITE_OK }
        let sql = "SELECT * FROM Compras WHERE id_producto = ? LIMIT 1"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &readEntryStmt, nil)
        if  r != SQLITE_OK
        {
            logDbErr("sqlite3_prepare readEntryStmt")
        }
        return r
    }
    
    func prepareReadAllEntryStmt() -> Int32
    {
        guard readEntryStmt == nil else { return SQLITE_OK }
        let sql = "SELECT * FROM Compras"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &readEntryStmt, nil)
        if  r != SQLITE_OK
        {
            logDbErr("sqlite3_prepare readAllEntryStmt")
        }
        return r
    }
    
    func prepareDeleteEntryStmt() -> Int32
    {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        let sql = "DELETE FROM Compras WHERE id_producto = ?"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &deleteEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    func prepareCountEntryStmt() -> Int32
    {
        guard readEntryStmt == nil else { return SQLITE_OK }
        let sql = "SELECT COUNT(*) FROM Compras"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &deleteEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    func insert(producto:Producto)
    {
        guard self.prepareInsertEntryStmt() == SQLITE_OK else { return }
        
        defer
        {
            sqlite3_reset(self.insertEntryStmt)
        }
        
        if sqlite3_bind_text(self.insertEntryStmt, 1, (producto.id as NSString).utf8String, -1, nil) != SQLITE_OK
        {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        if sqlite3_bind_text(self.insertEntryStmt, 2, (producto.nombre as NSString).utf8String, -1, nil) != SQLITE_OK
        {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        if sqlite3_bind_text(self.insertEntryStmt, 3, (producto.precio.stringValue as NSString).utf8String, -1, nil) != SQLITE_OK
        {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        if sqlite3_bind_text(self.insertEntryStmt, 4, (producto.ruta_imagen as NSString).utf8String, -1, nil) != SQLITE_OK
        {
            logDbErr("sqlite3_bind_text(insertEntryStmt)")
            return
        }
        
        //executing the query to insert values
        let r = sqlite3_step(self.insertEntryStmt)
        
        if r != SQLITE_DONE
        {
            logDbErr("sqlite3_step(insertEntryStmt) \(r)")
            return
        }
    }
    
    func getAll() throws -> [Producto]
    {
        guard self.prepareReadAllEntryStmt() == SQLITE_OK else { throw SqliteError(message: "Error in prepareReadAllEntryStmt") }
        
        defer
        {
            sqlite3_reset(self.readEntryStmt)
        }
        
        var productos:[Producto] = [Producto]();
        
        while(sqlite3_step(readEntryStmt) == SQLITE_ROW)
        {
            let producto:Producto = Producto();
            producto.id = String(sqlite3_column_int(readEntryStmt, 1));
            producto.nombre = String(cString: sqlite3_column_text(readEntryStmt, 2));
            producto.precio = NSNumber(value: Float(String(cString:sqlite3_column_text(readEntryStmt, 3))) ?? 0.0);
            producto.ruta_imagen = String(cString: sqlite3_column_text(readEntryStmt, 4));
            
            productos.append(producto);
        }
        
        return productos;
    }
    
    func delete(id: String)
    {
        // ensure statements are created on first usage if nil
        guard self.prepareDeleteEntryStmt() == SQLITE_OK else { return }
        
        defer {
            // reset the prepared statement on exit.
            sqlite3_reset(self.deleteEntryStmt)
        }
        
        //  At some places (esp sqlite3_bind_xxx functions), we typecast String to NSString and then convert to char*,
        // ex: (eventLog as NSString).utf8String. This is a weird bug in swift's sqlite3 bridging. this conversion resolves it.
        
        //Inserting name in deleteEntryStmt prepared statement
        if sqlite3_bind_text(self.deleteEntryStmt, 1, (id as NSString).utf8String, -1, nil) != SQLITE_OK
        {
            logDbErr("sqlite3_bind_text(deleteEntryStmt)")
            return
        }
        
        //executing the query to delete row
        let r = sqlite3_step(self.deleteEntryStmt)
        if r != SQLITE_DONE {
            logDbErr("sqlite3_step(deleteEntryStmt) \(r)")
            return
        }
    }
    
    func count() throws -> Int32
    {
        guard self.prepareCountEntryStmt() == SQLITE_OK else { throw SqliteError(message: "Error in prepareReadAllEntryStmt") }
        
        defer
        {
            sqlite3_reset(self.readEntryStmt)
        }
        
        if sqlite3_bind_text(self.readEntryStmt, 1, "", -1, nil) != SQLITE_OK
        {
            logDbErr("sqlite3_bind_text(deleteEntryStmt)")
            return 0
        }
        
        return sqlite3_column_int(readEntryStmt, 1);
    }
    
    func logDbErr(_ msg: String)
    {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("ERROR \(msg)")
    }
}

class SqliteError : Error
{
    var message = ""
    var error = SQLITE_ERROR
    
    init(message: String = "") {
        self.message = message
    }
    init(error: Int32) {
        self.error = error
    }
}
