import 'dart:io';

void main() {
  print(countyAverage(1001));
  print("expected:");
}
double countyAverage(int zip) {
  File covidData = new File("~/assets/covidData.csv");
  List<String> dataList = covidData.readAsLinesSync();
  Pattern zips = ''+zip.toString();
  String line = dataList.firstWhere((e) => e.startsWith(zips));
  List<String> countyList = line.split(',');
  List<int> countyListInt = countyList.map(int.parse).toList();
  int total = 0;
    for (int i = countyListInt.length - 7; i < countyListInt.length; i++) {
      total += countyListInt.elementAt(i);
    }
    double sum = total.toDouble();
    return sum / 7.0;
}