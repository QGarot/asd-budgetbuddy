import 'package:uuid/uuid.dart';

class IdGenerator {
  static String generateRandomUniqueId() {
    var uuid = Uuid();
    return uuid.v4().replaceAll("-", "").substring(0, 10);
  }
}
