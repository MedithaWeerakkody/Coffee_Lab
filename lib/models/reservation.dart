class Reservation {
  final String id;
  final String userId;
  final DateTime date;
  final String time;
  final int guests;
  final String status;

  Reservation({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
  });

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      time: map['time'] ?? '',
      guests: map['guests'] ?? 1,
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'time': time,
      'guests': guests,
      'status': status,
    };
  }
}
