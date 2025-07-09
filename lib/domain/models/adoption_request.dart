class AdoptionRequest {
  final String id;
  final String petId;
  final String petName;
  final String petOwnerId;
  final String userId;
  final String userEmail;
  final String status; // pendiente, aceptada, rechazada

  AdoptionRequest({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petOwnerId,
    required this.userId,
    required this.userEmail,
    required this.status,
  });

  factory AdoptionRequest.fromMap(Map<String, dynamic> map, String id) {
    return AdoptionRequest(
      id: id,
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? '',
      petOwnerId: map['petOwnerId'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      status: map['status'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toMap() => {
        'petId': petId,
        'petName': petName,
        'petOwnerId': petOwnerId,
        'userId': userId,
        'userEmail': userEmail,
        'status': status,
      };
}