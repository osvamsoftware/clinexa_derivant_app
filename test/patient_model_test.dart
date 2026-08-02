import 'package:clinexa_derivant_app/data/models/patient_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// El backend devuelve `specialties` y `pathologies` de dos formas distintas:
/// al crear un paciente se envían como identificadores, pero al leerlo llegan
/// enriquecidas como objetos `{id, name, description, ...}`.
///
/// Un `List<String>.from(...)` sobre esos objetos lanzaba un `TypeError` que
/// tumbaba la deserialización de la lista entera: la pantalla "Mis pacientes"
/// mostraba "Error realizando la petición HTTP" pese a que la respuesta era un
/// 200 correcto. No se veía porque los pacientes antiguos tenían la lista
/// vacía; bastaba un paciente con especialidad para romper la pantalla.
void main() {
  group('PatientModel.fromMap', () {
    test('acepta specialties como lista de objetos enriquecidos', () {
      final json = {
        '_id': 'p1',
        'first_name': 'Ana',
        'last_name': 'Pérez',
        'specialties': [
          {'id': 's1', 'name': 'Cardiología', 'description': 'x'},
          {'id': 's2', 'name': 'Neurología', 'description': 'y'},
        ],
        'pathologies': [
          {'id': 'pa1', 'name': 'Hipertensión'},
        ],
      };

      final paciente = PatientModel.fromMap(json);

      expect(paciente.specialties, ['s1', 's2']);
      expect(paciente.pathologies, ['pa1']);
    });

    test('sigue aceptando specialties como lista de identificadores', () {
      final paciente = PatientModel.fromMap({
        '_id': 'p2',
        'first_name': 'Luis',
        'last_name': 'Gómez',
        'specialties': ['s1', 's2'],
        'pathologies': ['pa1'],
      });

      expect(paciente.specialties, ['s1', 's2']);
      expect(paciente.pathologies, ['pa1']);
    });

    test('tolera listas ausentes o vacías', () {
      final paciente = PatientModel.fromMap({
        '_id': 'p3',
        'first_name': 'Sin',
        'last_name': 'Listas',
      });

      expect(paciente.specialties, isEmpty);
      expect(paciente.pathologies, isEmpty);
    });

    test('descarta entradas sin identificador en vez de fallar', () {
      final paciente = PatientModel.fromMap({
        '_id': 'p4',
        'first_name': 'Datos',
        'last_name': 'Raros',
        'specialties': [
          {'name': 'Sin id'},
          {'id': 's9', 'name': 'Con id'},
          '',
        ],
      });

      expect(paciente.specialties, ['s9']);
    });
  });
}
