const MONTHS = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
];

String dateToWord(DateTime date) {
  var mm = date.month;
  var dd = date.day;
  var yyyy = date.year;
  return "${MONTHS[mm - 1]} $dd, $yyyy at ${date.hour}:${date.minute}";
}
