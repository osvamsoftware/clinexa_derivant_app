// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get fieldRequired => 'Completa este campo.';

  @override
  String get welcomeSubtitle => 'Compartiendo salud';

  @override
  String get welcomeDescription =>
      'Clinexapp conecta a médicos referentes con equipos de investigación clínica, de forma segura y transparente.';

  @override
  String get loginHello => '¡Hola!';

  @override
  String get welcomeTitle => 'Te damos la bienvenida';

  @override
  String get emailOrMobile => 'Correo Electrónico o Móvil';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPasswordOld => '¿Olvidaste la Contraseña?';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get or => 'o';

  @override
  String get dontHaveAccount => '¿Aún no tienes cuenta?';

  @override
  String get signup => 'Crear cuenta';

  @override
  String get invalidEmail =>
      'Ingresa un correo válido, por ejemplo nombre@ejemplo.com.';

  @override
  String get invalidPhone =>
      'Ingresa un teléfono válido, de 6 a 12 dígitos y sin espacios.';

  @override
  String get passwordMin => 'Usa al menos 8 caracteres.';

  @override
  String get passwordMax => 'Usa como máximo 128 caracteres.';

  @override
  String get passwordComplexity => 'Combina mayúsculas, minúsculas y números.';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get invalidName => 'El nombre contiene caracteres no válidos.';

  @override
  String get invalidLastName => 'El apellido contiene caracteres no válidos.';

  @override
  String get invalidCode =>
      'Por favor, introduce un código de 3 dígitos válido.';

  @override
  String get invalidMemberId => 'El ID de miembro debe tener 8 caracteres.';

  @override
  String get invalidDni => 'Ingresa un número válido de más de 6 dígitos.';

  @override
  String get loading => 'Cargando…';

  @override
  String get errorOccurred => 'No se pudo completar';

  @override
  String get ok => 'Entendido';

  @override
  String get accept => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get noTitle => 'Sin título';

  @override
  String get registerDoctor => 'Registro de Médico';

  @override
  String get email => 'Correo electrónico';

  @override
  String get medicalLicense => 'Número de matrícula';

  @override
  String get specialty => 'Especialidad';

  @override
  String get specialtyExample => 'Cardiología';

  @override
  String get add => 'Agregar';

  @override
  String get biography => 'Biografía';

  @override
  String get biographyHint => 'Cuéntanos sobre tu experiencia...';

  @override
  String get country => 'País';

  @override
  String get city => 'Ciudad';

  @override
  String get address => 'Dirección';

  @override
  String get streetExample => 'Calle 123';

  @override
  String get createAccount => 'Crea tu cuenta';

  @override
  String get unexpectedError =>
      'Ocurrió un error inesperado. Intenta de nuevo.';

  @override
  String get searchSpecialty => 'Especialidades';

  @override
  String get register_step1_title => 'Datos personales';

  @override
  String get register_firstName => 'Nombre';

  @override
  String get register_lastName => 'Apellido';

  @override
  String get register_email => 'Correo electrónico';

  @override
  String get register_password => 'Contraseña';

  @override
  String get register_next => 'Continuar';

  @override
  String get register_basicInfo_description =>
      'Ingresa tu información básica para continuar.';

  @override
  String get register_header =>
      'Completa tus datos para empezar a derivar pacientes a ensayos clínicos.';

  @override
  String get specialty_required => 'Agrega al menos una especialidad.';

  @override
  String get register_successMessage =>
      'Ya puedes iniciar sesión con tu correo y contraseña.';

  @override
  String get error400 => 'Solicitud incorrecta (400)';

  @override
  String get error401 => 'Tu sesión no está autorizada (401)';

  @override
  String get error403 => 'Acceso denegado (403)';

  @override
  String get error404 => 'No encontramos el recurso (404)';

  @override
  String get error408 => 'El servidor tardó demasiado (408)';

  @override
  String get error500 => 'Error del servidor (500)';

  @override
  String get error503 => 'Servicio no disponible (503)';

  @override
  String get errorUnknown => 'Ocurrió un error';

  @override
  String get errorGenericMessage =>
      'No se pudo procesar tu solicitud. Intenta de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get patientList => 'Lista de pacientes';

  @override
  String get protocolsList => 'Lista de Protocolos';

  @override
  String get filterProtocols => 'Filtrar protocolos';

  @override
  String get selectSpecialty => 'Seleccionar especialidad';

  @override
  String get errorLoadingSpecialties => 'Error al cargar especialidades';

  @override
  String get pathology => 'Patología';

  @override
  String get selectPathology => 'Seleccionar patología';

  @override
  String get searchByName => 'Por nombre';

  @override
  String get noProtocolsFound => 'No encontramos protocolos';

  @override
  String get loadingSpecialties => 'Cargando especialidades...';

  @override
  String get loadingPathologies => 'Cargando patologías...';

  @override
  String get protocolDetails => 'Verificar criterios';

  @override
  String get patientCriteria => 'Requisitos del Paciente (Criterios)';

  @override
  String get addToMyList => 'Añadir a mi lista de protocolos';

  @override
  String get removeFromMyList => 'Eliminar de mi lista de protocolos';

  @override
  String get protocolAddedSuccessfully => 'Protocolo añadido con éxito';

  @override
  String get protocolRemovedSuccessfully => 'Protocolo eliminado con éxito';

  @override
  String get errorLoadingProtocols =>
      'No se pudieron cargar los protocolos. Desliza hacia abajo para reintentar.';

  @override
  String get seeMore => 'Ver más';

  @override
  String get filters => 'Filtros';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get results => 'Resultados';

  @override
  String get protocolSelectionSubtitle =>
      'Elige un protocolo y verifica que tu paciente cumpla los criterios.';

  @override
  String get continue_text => 'Continuar';

  @override
  String get protocolCriteriaVerificationInfo =>
      'Marca los criterios que cumple tu paciente. Para derivarlo debe cumplirlos todos.';

  @override
  String get homeWelcomeBack => 'Hola de nuevo';

  @override
  String get homeSearchHint => 'Buscar pacientes...';

  @override
  String get homeSearchResults => 'Resultados de Búsqueda';

  @override
  String get homePathology => 'Patologías';

  @override
  String get homeSpecialty => 'Especialidad';

  @override
  String get exampleMigraine => 'Migraña Crónica';

  @override
  String get exampleHypertension => 'Hipertensión';

  @override
  String get exampleArrhythmia => 'Arritmia';

  @override
  String get exampleNeurology => 'Neurología';

  @override
  String get exampleCardiology => 'Cardiología';

  @override
  String get searchPatient => 'Buscar Paciente';

  @override
  String get navHome => 'Inicio';

  @override
  String get navPatients => 'Pacientes';

  @override
  String get navProtocols => 'Protocolos';

  @override
  String get navMessages => 'Mensajes';

  @override
  String get viewMyProtocols => 'Mis protocolos';

  @override
  String get registerPatient => 'Datos del paciente';

  @override
  String get dni => 'DNI';

  @override
  String get gender => 'Género';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get phone => 'Teléfono';

  @override
  String get notes => 'Notas';

  @override
  String get personalInfo => 'Datos personales';

  @override
  String get contactInfo => 'Contacto';

  @override
  String get medicalInfo => 'Información médica';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get other => 'Otro';

  @override
  String get save => 'Guardar';

  @override
  String get criteriaNotMet => 'Faltan criterios por confirmar';

  @override
  String get showAll => 'Ver todos';

  @override
  String allCriteriaFor(Object name) {
    return 'Todos los criterios para $name';
  }

  @override
  String get close => 'Cerrar';

  @override
  String stepXofY(Object step, Object total) {
    return 'Paso $step de $total';
  }

  @override
  String get nextRegister => 'Continuar con los datos del paciente';

  @override
  String get nextStep => 'Siguiente paso';

  @override
  String get searchSpecialtyHint => 'Ej.: Cardiología';

  @override
  String get searchPathologyHint => 'Buscar patología...';

  @override
  String get notAllCriteriaMet =>
      'Para seguir, confirma todos los criterios de este paso. Si tu paciente no cumple alguno, no puede derivarse a este protocolo.';

  @override
  String get myPatients => 'Mis pacientes';

  @override
  String get noPatientsFound => 'Aún no tienes pacientes';

  @override
  String get patientCreatedSuccessfully => 'El paciente quedó registrado.';

  @override
  String get search => 'Buscar';

  @override
  String get all => 'Todos';

  @override
  String get payForFullData => 'Dato protegido';

  @override
  String get hiddenField => 'Oculto';

  @override
  String get orderStatusAssigned => 'En evaluación';

  @override
  String get orderStatusAccepted => 'Aceptado';

  @override
  String get orderStatusRejected => 'Rechazado';

  @override
  String get patientDetails => 'Ficha del paciente';

  @override
  String get partialData => 'Datos parciales';

  @override
  String get protocol => 'Protocolo';

  @override
  String get provinceState => 'Provincia o estado';

  @override
  String get appName => 'Clinexapp';

  @override
  String get userNotAuthenticated =>
      'Tu sesión no está activa. Vuelve a iniciar sesión.';

  @override
  String get searchAddress => 'Buscar dirección...';

  @override
  String get searchAddressPrompt => 'Escribe y elige una sugerencia';

  @override
  String get paymentProcessedSuccessfully => 'Pago procesado correctamente';

  @override
  String get paymentIntentNotAvailable =>
      'Payment intent ID o client secret no disponibles';

  @override
  String get errorSearchingAddresses => 'Error al buscar direcciones';

  @override
  String get addressDetailsNotFound =>
      'No se encontraron detalles de la dirección';

  @override
  String get errorGettingDetails => 'Error al obtener detalles';

  @override
  String get selectValidAddress =>
      'Elige una dirección de la lista de sugerencias.';

  @override
  String get errorVerifyingUserStatus =>
      'No pudimos verificar tu cuenta. Vuelve a iniciar sesión.';

  @override
  String get noRefreshTokenFound => 'No se encontró token de actualización';

  @override
  String get noAddress => 'Sin dirección';

  @override
  String get postalCode => 'Código postal';

  @override
  String get status => 'Estado';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusInactive => 'Inactivo';

  @override
  String get markAsInactive => 'Marcar como inactivo';

  @override
  String get confirmAction => 'Confirma la acción';

  @override
  String get confirmMarkAsInactive =>
      'El paciente dejará de estar disponible para los protocolos. Puedes volver a activarlo cuando quieras.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get noOrderLinked => 'Aún sin orden';

  @override
  String get activeOrder => 'Orden activa';

  @override
  String get orderId => 'ID de orden';

  @override
  String get orderStatus => 'Estado de la Orden';

  @override
  String get professionalFees =>
      'Honorarios profesionales por la evaluación del paciente';

  @override
  String get whatsappVerificationNoticeDetailed =>
      'Avisa al paciente que necesita conexión a internet y acceso a su WhatsApp para recibirlo.';

  @override
  String get noPatientsPromotion =>
      'Deriva a tu primer paciente a un protocolo de investigación desde Inicio.';

  @override
  String get markAsActive => 'Marcar como activo';

  @override
  String get confirmMarkAsActive =>
      'El paciente volverá a estar disponible para los protocolos.';

  @override
  String get licenseType => 'Tipo de matrícula';

  @override
  String get provincialLicense => 'Matrícula provincial';

  @override
  String get nationalLicense => 'Matrícula nacional';

  @override
  String get phone2 => 'Teléfono adicional';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get forgotPasswordDescription =>
      'Ingresa el correo de tu cuenta y te enviaremos un enlace para crear una contraseña nueva.';

  @override
  String get sendInstructions => 'Enviar enlace';

  @override
  String get recoveryEmailSent =>
      'Te enviamos un enlace para restablecer tu contraseña. Si no lo ves, revisa la carpeta de spam.';

  @override
  String get resetPassword => 'Crea una contraseña nueva';

  @override
  String get newPassword => 'Contraseña nueva';

  @override
  String get confirmNewPassword => 'Repite la contraseña nueva';

  @override
  String get passwordResetSuccess =>
      'Ya puedes iniciar sesión con tu contraseña nueva.';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get notificationScreenTitle => 'Notificaciones';

  @override
  String get noNotificationsFound => 'No tienes notificaciones';

  @override
  String get notificationMarkedAsRead => 'Notificación marcada como leída';

  @override
  String get errorLoadingNotifications =>
      'No se pudieron cargar las notificaciones';

  @override
  String get cantFindProtocol => '¿No encuentras tu protocolo? ';

  @override
  String get contactUsHere => 'Contáctanos aquí';

  @override
  String get contactTitle => 'Solicita un protocolo nuevo';

  @override
  String get contactSubtitle => 'Contacto';

  @override
  String get contactDescription =>
      'Escribe al equipo de gestión de Clinexapp por WhatsApp para pedir el alta o la modificación de un protocolo.';

  @override
  String get contactSchedule => 'Horario de atención: 08:00 a 18:00';

  @override
  String get contactButton => 'Escribir por WhatsApp';

  @override
  String contactMessage(String name, String license, String id) {
    return 'Soy el médico $name, con matrícula $license e ID de usuario $id. Quiero solicitar el alta de un nuevo protocolo en la app.';
  }

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get personalInformation => 'Datos personales';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get specialties => 'Especialidades';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get profileUpdatedSuccess => 'Guardamos tus cambios.';

  @override
  String get requiredField => 'Completa este campo.';

  @override
  String get errorUnauthorized => 'Tu sesión expiró. Vuelve a iniciar sesión.';

  @override
  String get errorLoginFailed =>
      'No se pudo iniciar sesión. Revisa tus datos e intenta de nuevo.';

  @override
  String get errorInvalidCredentials =>
      'El correo o la contraseña no son correctos.';

  @override
  String get errorNetwork =>
      'No se pudo conectar con el servidor. Revisa tu conexión.';

  @override
  String get errorServer =>
      'El servidor tuvo un problema. Intenta de nuevo en unos minutos.';

  @override
  String get errorServiceUnavailable =>
      'El servicio no está disponible en este momento. Intenta más tarde.';

  @override
  String get errorValidation =>
      'Algunos datos no son válidos. Revísalos e intenta de nuevo.';

  @override
  String get errorNotFound => 'No encontramos lo que buscas.';

  @override
  String get errorForbidden => 'No tienes permiso para hacer esta acción.';

  @override
  String get errorGeneric => 'Ocurrió un error. Intenta de nuevo.';

  @override
  String get signature => 'Firma del paciente';

  @override
  String get errorLoadingImage => 'No se pudo cargar la firma';

  @override
  String get paymentBonusPending =>
      'Aún no ha recibido sus honorarios profesionales por el tiempo dedicado a la evaluación de este paciente. Por favor, espere a que uno de nuestros agentes se ponga en contacto con usted.';

  @override
  String get paymentBonusCompleted =>
      'Sus honorarios profesionales por el tiempo dedicado a la evaluación de este paciente han sido procesados. Continúe realizando diagnósticos y evaluaciones para seguir percibiendo honorarios por sus servicios.';

  @override
  String get paymentMovementNotFound =>
      'No hay movimientos registrados con este usuario, contacte con soporte.';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get searchPatientsInvite => 'Search Patients';

  @override
  String pathologiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count patologías',
      one: '1 patología',
    );
    return '$_temp0';
  }

  @override
  String get errorRoleReceptor =>
      'Este email se registró como receptor. Prueba creando una cuenta con un nuevo email.';

  @override
  String get wrongRoleTitle => 'Estás en la app equivocada';

  @override
  String get wrongRoleMessageDerivante =>
      'Esta app es para médicos referentes, pero tu cuenta es de investigador. Descarga Clinexapp Investigador o inicia sesión con una cuenta de médico referente.';

  @override
  String get wrongRoleExitButton => 'Volver a iniciar sesión';

  @override
  String get notif_patient_rejected_title => 'Paciente rechazado';

  @override
  String notif_patient_rejected_body(String patient_name, String notes) {
    return '$patient_name no fue aceptado. Nota: $notes';
  }

  @override
  String get notif_prospect_patient_title => 'Nuevo prospecto';

  @override
  String notif_prospect_patient_body(String patient_name) {
    return 'Se registró un paciente nuevo como prospecto en uno de tus protocolos.';
  }

  @override
  String get notif_patient_assigned_title => 'Paciente derivado';

  @override
  String notif_patient_assigned_body(String patient_name) {
    return 'Tu paciente $patient_name fue derivado y será evaluado para participar en el estudio.';
  }

  @override
  String get notif_patient_taken_title => 'Paciente en evaluación';

  @override
  String notif_patient_taken_body(String patient_name) {
    return 'Un investigador tomó a tu paciente $patient_name para evaluarlo.';
  }

  @override
  String get notif_patient_accepted_title => 'Paciente aceptado';

  @override
  String notif_patient_accepted_body(String patient_name) {
    return '$patient_name fue aceptado para evaluación y posible participación en el estudio.';
  }

  @override
  String get welcomeHeadline => 'Deriva pacientes a ensayos clínicos';

  @override
  String get loginSubtitle => 'Ingresa con tu cuenta de médico referente.';

  @override
  String get emailHint => 'nombre@ejemplo.com';

  @override
  String get passwordHelper =>
      'Mínimo 8 caracteres, con mayúsculas, minúsculas y números.';

  @override
  String get forgotPasswordTitle => 'Recupera tu contraseña';

  @override
  String get recoveryEmailSentTitle => 'Revisa tu correo';

  @override
  String get backToLogin => 'Volver a iniciar sesión';

  @override
  String get resetPasswordDescription =>
      'Elige una contraseña que no hayas usado antes.';

  @override
  String get savePassword => 'Guardar contraseña';

  @override
  String get passwordResetSuccessTitle => 'Contraseña actualizada';

  @override
  String get registerStepProfessional => 'Datos profesionales';

  @override
  String get registerStepTerms => 'Términos';

  @override
  String get registerProfessionalSubtitle =>
      'Tu matrícula y tus especialidades definen qué protocolos ves.';

  @override
  String get registerTermsSubtitle =>
      'Lee los términos y acéptalos para crear tu cuenta.';

  @override
  String get termsAcceptLabel =>
      'Leí y acepto los términos y condiciones de Clinexapp y el compromiso que asumo al crear la cuenta.';

  @override
  String get termsTitle => 'Términos y condiciones de uso';

  @override
  String get registerSuccessTitle => 'Tu cuenta está lista';

  @override
  String get selectOption => 'Selecciona una opción';

  @override
  String get selectProvince => 'Selecciona una provincia';

  @override
  String get removeItem => 'Quitar';

  @override
  String get sessionCheckTitle => 'Preparando tu cuenta';

  @override
  String get successTitle => 'Listo';

  @override
  String get myProfile => 'Mi perfil';

  @override
  String get homeProtocolsTitle => 'Protocolos disponibles';

  @override
  String get searchByCategory => 'Por especialidad';

  @override
  String get searchProtocolHint => 'Busca por nombre del protocolo';

  @override
  String get selectPlaceholder => 'Selecciona';

  @override
  String criteriaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count criterios',
      one: '1 criterio',
    );
    return '$_temp0';
  }

  @override
  String get noProtocolsHint =>
      'Prueba con otra especialidad, patología o nombre.';

  @override
  String patientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pacientes registrados',
      one: '1 paciente registrado',
      zero: 'Sin pacientes registrados',
    );
    return '$_temp0';
  }

  @override
  String get searchPatientsHint => 'Busca por nombre';

  @override
  String get allSpecialties => 'Todas las especialidades';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get noPatientsResultsHint => 'Prueba con otro nombre o especialidad.';

  @override
  String get referPatientAction => 'Ver protocolos';

  @override
  String get allCriteriaTitle => 'Todos los criterios';

  @override
  String get criteriaStepLabel => 'Criterios';

  @override
  String get criteriaChecklistLabel => 'Confirma cada criterio';

  @override
  String criteriaCheckedCount(int checked, int total) {
    return '$checked de $total';
  }

  @override
  String get referralStepPatient => 'Datos del paciente';

  @override
  String get referralStepSignature => 'Firma';

  @override
  String get referralStepVerification => 'Verificación';

  @override
  String get patientRegistrationSubtitle =>
      'Completa los datos del paciente que vas a derivar. Los usaremos solo para este protocolo.';

  @override
  String get continueToSignature => 'Continuar a la firma';

  @override
  String get datePlaceholder => 'AAAA-MM-DD';

  @override
  String get autoFilled => 'Se completa solo';

  @override
  String get notesHint =>
      'Antecedentes, tratamiento actual u otra información útil';

  @override
  String get signatureHandOverTitle => 'Entrega el dispositivo al paciente';

  @override
  String get signatureInstructions =>
      'Pídele que firme en el recuadro de abajo. Cuando termine, toca Continuar.';

  @override
  String get signatureAreaLabel => 'Espacio de firma';

  @override
  String get signaturePlaceholder => 'Firma aquí con el dedo o un lápiz óptico';

  @override
  String get clearSignature => 'Borrar firma';

  @override
  String get signatureRequired => 'Pide al paciente que firme para continuar.';

  @override
  String get continueToVerification => 'Continuar a la verificación';

  @override
  String get whatsappVerificationTitle => 'Verificación por WhatsApp';

  @override
  String get whatsappVerificationSubtitle =>
      'Enviaremos un código por WhatsApp al paciente para confirmar su número.';

  @override
  String get patientWhatsapp => 'WhatsApp del paciente';

  @override
  String get importantNotice => 'Antes de enviar el código';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get verificationCodeTitle => 'Código de verificación';

  @override
  String get verificationCodeSubtitle =>
      'Ingresa el código de 6 dígitos que recibió el paciente.';

  @override
  String get codeNotReceived => '¿No llegó el código?';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String resendCodeIn(String time) {
    return 'Reenviar en $time';
  }

  @override
  String get verifyAndRegister => 'Verificar y derivar paciente';

  @override
  String get errorVerifyingCode =>
      'No se pudo verificar el código. Revísalo e intenta de nuevo.';

  @override
  String get errorSavingPatient =>
      'No se pudo registrar al paciente. Intenta de nuevo.';

  @override
  String get patientReferredTitle => 'Paciente derivado';

  @override
  String get patientReferredMessage =>
      'Lo verás en Mis pacientes con su estado actualizado.';

  @override
  String get seeMyPatients => 'Ver mis pacientes';

  @override
  String get partialDataMessage =>
      'Algunos datos están ocultos por privacidad.';

  @override
  String get noOrderLinkedMessage =>
      'Cuando un investigador tome a tu paciente, aquí verás el estado de la orden y tus honorarios.';

  @override
  String get rejectionReason => 'Motivo del rechazo';

  @override
  String get acceptanceNotes => 'Notas de aceptación';

  @override
  String specialtiesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count especialidades',
      one: '1 especialidad',
    );
    return '$_temp0';
  }

  @override
  String get markAsInactiveTitle => '¿Marcar como inactivo?';

  @override
  String get markAsActiveTitle => '¿Marcar como activo?';

  @override
  String get markAsInactiveHelper =>
      'Puedes cambiarlo mientras ningún investigador haya tomado al paciente.';

  @override
  String get markAsActiveHelper =>
      'Puedes cambiarlo mientras ningún investigador haya tomado al paciente.';

  @override
  String get notificationDetailTitle => 'Notificación';

  @override
  String get notificationDetails => 'Detalles';

  @override
  String get noNotificationsHint =>
      'Aquí te avisaremos cuando un investigador evalúe a tus pacientes.';

  @override
  String get unread => 'Nueva';

  @override
  String get specialtiesProfileHint => 'Definen qué protocolos ves en Inicio.';

  @override
  String get profileUpdatedTitle => 'Perfil actualizado';

  @override
  String licenseBadge(String license) {
    return 'Matrícula $license';
  }

  @override
  String get accountSection => 'Cuenta';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutSubtitle => 'Sales de Clinexapp en este dispositivo.';

  @override
  String get logoutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get logoutConfirmMessage =>
      'Para volver a entrar necesitarás tu correo y contraseña.';

  @override
  String get contactChecklistTitle => 'Ten a mano';

  @override
  String get contactChecklist1 => 'El nombre o código del protocolo.';

  @override
  String get contactChecklist2 => 'El centro de investigación que lo lleva.';

  @override
  String get contactChecklist3 => 'Qué quieres agregar o modificar.';

  @override
  String get whatsappOpenError =>
      'No se pudo abrir WhatsApp. Revisa que esté instalado e intenta de nuevo.';

  @override
  String get patientLabel => 'Paciente';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
      zero: 'Sin resultados',
    );
    return '$_temp0';
  }
}
