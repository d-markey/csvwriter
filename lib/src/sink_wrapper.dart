abstract class SinkWrapper {
  Future get done;
  Future flush();
  Future close();
  void write(String data);
}
