import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new reservation
  Future<String?> createReservation({
    required String userId,
    required DateTime date,
    required String time,
    required int guests,
  }) async {
    try {
      final reservationData = {
        'userId': userId,
        'date': date.millisecondsSinceEpoch,
        'time': time,
        'guests': guests,
        'status': 'Pending',
      };

      DocumentReference docRef = await _firestore
          .collection('reservations')
          .add(reservationData);

      return docRef.id;
    } catch (e) {
      print('Create reservation error: $e');
      return null;
    }
  }

  // Get user reservations with error handling
  Stream<List<Reservation>> getUserReservations(String userId) {
    try {
      return _firestore
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            var reservations = snapshot.docs
                .map((doc) => Reservation.fromMap({...doc.data(), 'id': doc.id}))
                .toList();
            
            // Sort in memory instead of using composite index
            reservations.sort((a, b) => b.date.compareTo(a.date));
            return reservations;
          })
          .handleError((error) {
            print('Error fetching reservations: $error');
            return <Reservation>[];
          });
    } catch (e) {
      print('getUserReservations error: $e');
      // Return empty stream on error
      return Stream.value(<Reservation>[]);
    }
  }

  // Update reservation status
  Future<void> updateReservationStatus(String reservationId, String status) async {
    try {
      await _firestore
          .collection('reservations')
          .doc(reservationId)
          .update({'status': status});
    } catch (e) {
      print('Update reservation status error: $e');
    }
  }

  // Cancel reservation
  Future<void> cancelReservation(String reservationId) async {
    await updateReservationStatus(reservationId, 'Cancelled');
  }
}
