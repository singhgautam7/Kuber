/// Developer contact address and the pre-filled email templates the knowledge
/// handler's `EmailChipAction`s use. English-only, like the rest of Ask Kuber.
///
/// `{version}` and `{device}` in a body are replaced at launch time with the
/// real app version (`package_info_plus`) and device model (`device_info_plus`)
/// by the Ask Kuber screen before the `mailto:` URI is built.
class EmailTemplates {
  const EmailTemplates._();

  /// The single developer contact address surfaced across Ask Kuber's help
  /// answers.
  static const developerEmail = 'singhgautam.dev@gmail.com';

  static const feedbackSubject = 'Kuber feedback';
  static const feedbackBody = '\n\n---\nApp version: {version}\nDevice: {device}';

  static const bugReportSubject = 'Kuber bug report';
  static const bugReportBody =
      'What happened:\n\nSteps to reproduce:\n\n---\nApp version: {version}\n'
      'Device: {device}';

  static const studentProSubject = 'Kuber Pro request';
  static const studentProBody =
      'Hi,\n\nI would like to request Kuber Pro access. Here are my details:\n\n'
      '[Please add student ID / situation]\n\nThanks!';

  static const generalSubject = 'Kuber';
  static const generalBody = '';
}
