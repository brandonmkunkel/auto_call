import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:auto_call/services/phone_list.dart';


Future<Database> openPhoneDatabase({@required String name}) async {
  // Open the database and store the reference.
  return openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), '$name.db'),

    // When the database is first created, create a table to store people.
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE people(id INTEGER PRIMARY KEY, name TEXT, phone TEXT)",
      );
    },

    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );
}

Future<void> insertPerson(Database db, Person person) async {
  // Insert the Person into the correct table. Also specify the
  // `conflictAlgorithm`. In this case, if the same person is inserted
  // multiple times, it replaces the previous data.
  await db.insert(
    'people',
    person.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Person>> people(Database db) async {
  // Query the table for all The Persons.
  final List<Map<String, dynamic>> maps = await db.query('people');

  // Convert the List<Map<String, dynamic> into a List<Person>.
  return List.generate(maps.length, (i) {
    return Person(
      id: maps[i]['id'],
      name: maps[i]['name'],
      phone: maps[i]['phone'],
    );
  });
}

Future<void> updatePerson(Database db, Person person) async {
  // Update the given Person.
  await db.update(
    'people',
    person.toMap(),

    // Ensure that the Person has a matching id.
    where: "id = ?",

    // Pass the Person's id as a whereArg to prevent SQL injection.
    whereArgs: [person.id],
  );
}

Future<void> deletePerson(Database db, int id) async {
  // Remove the Person from the database.
  await db.delete(
    'people',

    // Use a `where` clause to delete a specific person.
    where: "id = ?",

    // Pass the Person's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}
