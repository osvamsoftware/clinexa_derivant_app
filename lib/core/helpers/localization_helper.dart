import '../../l10n/app_localizations.dart';

class LocalizationHelper {
  static String translateNotificationKey(
    S s,
    String key,
    Map<String, dynamic> data,
  ) {
    switch (key) {
      case 'notif_patient_rejected_title':
        return s.notif_patient_rejected_title;
      case 'notif_patient_rejected_body':
        return s.notif_patient_rejected_body(
          data['patient_name']?.toString() ?? '',
          data['notes']?.toString() ?? '',
        );
      case 'notif_prospect_patient_title':
        return s.notif_prospect_patient_title;
      case 'notif_prospect_patient_body':
        return s.notif_prospect_patient_body(
          data['patient_name']?.toString() ?? '',
        );
      case 'notif_patient_accepted_title':
        return s.notif_patient_accepted_title;
      case 'notif_patient_accepted_body':
        return s.notif_patient_accepted_body(
          data['patient_name']?.toString() ?? '',
        );
      //assigned
      case 'notif_patient_assigned_title':
        return s.notif_patient_assigned_title;
      case 'notif_patient_assigned_body':
        return s.notif_patient_assigned_body(
          data['patient_name']?.toString() ?? '',
        );
      //taken (primer pago del receptor)
      case 'notif_patient_taken_title':
        return s.notif_patient_taken_title;
      case 'notif_patient_taken_body':
        return s.notif_patient_taken_body(
          data['patient_name']?.toString() ?? '',
        );
      default:
        return key; // Fallback to raw string if no translation is found
    }
  }
}
