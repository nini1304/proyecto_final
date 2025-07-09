import 'package:hive/hive.dart';
import '../../../domain/models/breed.dart';
import 'hive_boxes.dart';

class BreedLocalDataSource {
  final Box<String> _box = HiveBoxes.getBreedsBox();

  List<String> getAllBreeds() => _box.values.toList();

  Future<void> addBreed(String breed) async {
    if (!_box.values.contains(breed)) {
      await _box.add(breed);
    }
  }
}
