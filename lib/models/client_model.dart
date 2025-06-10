enum PhoneCountry { saudi, yemen }
enum VisaType { visit, work, umrah, hajj }
enum ClientStatus { green, yellow, red, white }

class ClientModel {
  final String id;
  final String clientName;
  final String clientPhone;
  final PhoneCountry phoneCountry;
  final VisaType visaType;
  final String? agentName;
  final String? agentPhone;
  final DateTime entryDate;
  final String notes;
  final String? visaImageUrl;
  final String? passportImageUrl;
  final ClientStatus status;
  final int daysRemaining;
  final bool hasExited;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientModel({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.phoneCountry,
    required this.visaType,
    this.agentName,
    this.agentPhone,
    required this.entryDate,
    required this.notes,
    this.visaImageUrl,
    this.passportImageUrl,
    required this.status,
    required this.daysRemaining,
    this.hasExited = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'phoneCountry': phoneCountry.toString().split('.').last,
      'visaType': visaType.toString().split('.').last,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'entryDate': entryDate.millisecondsSinceEpoch,
      'notes': notes,
      'visaImageUrl': visaImageUrl,
      'passportImageUrl': passportImageUrl,
      'status': status.toString().split('.').last,
      'daysRemaining': daysRemaining,
      'hasExited': hasExited,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      phoneCountry: PhoneCountry.values.firstWhere(
        (e) => e.toString().split('.').last == map['phoneCountry'],
        orElse: () => PhoneCountry.saudi,
      ),
      visaType: VisaType.values.firstWhere(
        (e) => e.toString().split('.').last == map['visaType'],
        orElse: () => VisaType.umrah,
      ),
      agentName: map['agentName'],
      agentPhone: map['agentPhone'],
      entryDate: DateTime.fromMillisecondsSinceEpoch(map['entryDate']),
      notes: map['notes'] ?? '',
      visaImageUrl: map['visaImageUrl'],
      passportImageUrl: map['passportImageUrl'],
      status: ClientStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ClientStatus.green,
      ),
      daysRemaining: map['daysRemaining'] ?? 0,
      hasExited: map['hasExited'] ?? false,
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  ClientModel copyWith({
    String? id,
    String? clientName,
    String? clientPhone,
    PhoneCountry? phoneCountry,
    VisaType? visaType,
    String? agentName,
    String? agentPhone,
    DateTime? entryDate,
    String? notes,
    String? visaImageUrl,
    String? passportImageUrl,
    ClientStatus? status,
    int? daysRemaining,
    bool? hasExited,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      phoneCountry: phoneCountry ?? this.phoneCountry,
      visaType: visaType ?? this.visaType,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      entryDate: entryDate ?? this.entryDate,
      notes: notes ?? this.notes,
      visaImageUrl: visaImageUrl ?? this.visaImageUrl,
      passportImageUrl: passportImageUrl ?? this.passportImageUrl,
      status: status ?? this.status,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      hasExited: hasExited ?? this.hasExited,
      createdBy: this.createdBy,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
