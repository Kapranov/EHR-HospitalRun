Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets')
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|woff2|ttf|otf)$/
Rails.application.config.assets.precompile += %w( *.eot *.woff *.ttf *.svg *.otf *.png *.jpg *.jpeg *.gif )
# Vendors
Rails.application.config.assets.precompile += [
  # Animate
  'animate/animate.css',
  # AnyLogin
  'any-login/any-login.css',
  'any-login/any-login.js',
  # Bootstrap
  'bootstrap/bootstrap.min.css',
  'bootstrap/bootstrap.min.js',
  # Bootstrap Date Picker
  'bootstrap-datepicker-custom/bootstrap-datepicker-custom.css',
  'bootstrap-datepicker-custom/bootstrap-datepicker-custom.js',
  # Bootstrap Dropdowns Enhancement
  'bootstrap-dropdowns-enhancement/dropdowns-enhancement.css',
  'bootstrap-dropdowns-enhancement/dropdowns-enhancement.js',
  # Bootstrap Table
  'bootstrap-table/bootstrap-table.css',
  'bootstrap-table/bootstrap-table.js',
  # Color Picker
  'color-picker/color-picker.css',
  'color-picker/color-picker.js',
  'color-picker/color-picker-theme.css',
  'color-picker/tinycolor-0.9.15.min.js',
  # FontAweome
  'font-awesome/font-awesome.css',
  # FullCalendar
  'fullcalendar/fullcalendar.css',
  'fullcalendar/fullcalendar.js',
  # jQuery Input Mask
  'jquery-inputmask/jquery.inputmask.bundle-custom.js',
  # jQuery Slim Scroll
  'jquery-slimscroll-custom/jquery-slimscroll-custom.css',
  'jquery-slimscroll-custom/jquery-slimscroll-custom.js',
  # jQuery UI
  'jquery-ui/jquery-ui-without-datepicker.min.js',
  # jQuery Updater
  'jquery-updater/jquery.periodicalupdater.js',
  'jquery-updater/jquery.updater.js',
  # jQuery Validation Plugin
  'jquery-validation/jquery.validate.js',
  'jquery-validation/additional-methods.js',
  # jQuery Bridget
  'jquery-bridget/jquery-bridget.js',
  # jQuery Magnificent JS
  'jquery-magnificentjs/mag.css',
  'jquery-magnificentjs/themes/default.css',
  'jquery-magnificentjs/mag.js',
  'jquery-magnificentjs/mag-jquery.js',
  # Moment
  'moment/moment.js',
  # nProgress
  'nprogress-custom/nprogress-custom.css',
  'nprogress-custom/nprogress-custom.js',
  # Select2
  'select2-custom/select2-custom.css',
  'select2-custom/select2-custom/themes/theme.css',
  'select2-custom/select2-custom/themes/theme_init.css',
  'select2-custom/select2-custom/themes/admin-black-white.css',
  'select2-custom/select2-custom/themes/gray-dark.css',
  'select2-custom/select2-custom/themes/gray-light.css',
  'select2-custom/select2-custom/themes/gray-lighter-highlight.css',
  'select2-custom/select2-custom/themes/gray-lighter.css',
  'select2-custom/select2-custom/themes/green-dark.css',
  'select2-custom/select2-custom/themes/green-light.css',
  'select2-custom/select2-custom/themes/green-lighter.css',
  'select2-custom/select2-custom/themes/green-white-dark.css',
  'select2-custom/select2-custom/themes/green-white-light.css',
  'select2-custom/select2-custom/themes/white-light.css',
  'select2-custom/select2-custom/themes/payments.css',
  'select2-custom/select2-custom/themes/audit-log.css',
  'select2-custom/select2-custom/themes/labs-imaging.css',
  'select2-custom/select2-custom.js'
]
# Admin
Rails.application.config.assets.precompile += [
  # UI
  'admin/ui/main.css',
  'admin/ui/main.js',
  'admin/ui/buttons.css',
  'admin/ui/checkboxes.css',
  'admin/ui/colors.css',
  'admin/ui/dropdowns.css',
  'admin/ui/fonts.css',
  'admin/ui/forms.css',
  'admin/ui/input-groups.css',
  'admin/ui/modals.css',
  # UI - Navigation
  'admin/ui/navigation/header.css',
  'admin/ui/navigation/side.css',
  'admin/ui/navigation/categories.css',
  # Main
  'admin/main.css',
  'admin/main.js',
  'admin/authorization.css',
  # Users
  'admin/users/main.css',
  'admin/users/modals.css'
]
# Providers
Rails.application.config.assets.precompile += [
  # Main
  'providers/main.css',
  'providers/main.js',
  # Billing
  'providers/billing/main.css',
  'providers/billing/main.js',
  # Calendars
  'calendars/main.css',
  'calendars/main.js',
  'calendars/calendars.js',
  'calendars/filter.js',
  # Calendars - Schedule
  'calendars/schedule/main.js',
  # Labs & Imaging
  'providers/labs_imaging/main.css',
  'providers/labs/modals.css',
  'providers/labs_imaging/main.js',
  'providers/labs_imaging/labs.js',
  'providers/labs_imaging/imaging.js',
  # Medline
  'providers/medline/main.css',
  'providers/medline/modals.css',
  # Patient Treatments
  'providers/patient_treatments/main.css',
  'providers/patient_treatments/main.js',
  'providers/patient_treatments/ammendment.css',
  'providers/patient_treatments/immunizations.css',
  'providers/patient_treatments/medical_history.css',
  'providers/patient_treatments/medical_history.js',
  'providers/patient_treatments/show_patient/chart.js',
  'providers/patient_treatments/show_patient/dental_chart.js',
  'providers/patient_treatments/show_patient/perio_chart.js',
  'providers/patient_treatments/show_patient/profile.js',
  'providers/patient_treatments/show_patient/insurance.js',
  'providers/patient_treatments/show_patient/erx.js',
  # Payments
  'providers/payments/main.css',
  'providers/payments/main.js',
  'providers/payments/card_info.js',
  'providers/payments/details.js',
  'providers/payments/order.js',
  'providers/payments/quote.js',
  # Reports
  'providers/reports/main.css',
  'providers/reports/main.js',
  # Settings
  'providers/settings/main.css',
  'providers/settings/main.js',
  # Settings - Access Permissions
  'providers/settings/access_permissions/main.css',
  'providers/settings/access_permissions/main.js',
  # Settings - Alerts
  'providers/settings/alerts/main.css',
  'providers/settings/alerts/main.js',
  'providers/settings/alerts/modals.css',
  # Settings - Audit
  'providers/settings/audit/main.css',
  'providers/settings/audit/main.js',
  # Settings - eRx
  'providers/settings/erx/main.css',
  'providers/settings/erx/main.js',
  # Settings - Education Materials
  'providers/settings/education_materials/main.css',
  'providers/settings/education_materials/main.js',
  'providers/settings/education_materials/modals.css',
  # Settings - Practice
  'providers/settings/practice/main.css',
  'providers/settings/practice/main.js',
  # Settings - Schedule
  'providers/settings/schedule/main.css',
  'providers/settings/schedule/main.js',
]
# Patients
Rails.application.config.assets.precompile += [
  # Main
  'patients/main.css',
  'patients/main.js',
  # Secure Questions
  'patients/secure_questions/main.css',
  'patients/secure_questions/main.js'
]
# Main
Rails.application.config.assets.precompile += [
  # UI
  'ui/main.css',
  'ui/main.js',
  'ui/fonts.css',
  'ui/colors.css',
  # Main
  'application.css',
  'application.js',
  # Appointments
  'appointments/main.css',
  'appointments/modals.css',
  # Attachments
  'attachment/main.css',
  'attachment/modals.css',
  # Authorization
  'authorization/main.css',
  'authorization/main.js',
  'authorization/duo.js',
  # Debug
  'debug/main.css',
  'debug/main.js',
  'debug/select2.css',
  'debug/select2.js',
  # Dosespot
  'dosespot/dosespot.css',
  # Email Messages
  'email_messages/main.css',
  'email_messages/main.js',
  'email_messages/modals.css',
  # Error
  'error/main.css',
  'error/main.js',
  # Helpers
  'helpers/sorter',
  'helpers/zipcode',
  # Landing
  'landing/main.css',
  'landing/main.js',
  # Mailer - UI
  'mailer/ui/main.css',
  'mailer/ui/colors.css',
  # Mailer - Main
  'mailer/main',
  'mailer/devise/confirmation_instructions.css',
  'mailer/invitations/send_invitation.css',
  'mailer/invitations/send_practice_invitation.css',
  'mailer/invitations/send_representative_invitation.css',
  'mailer/invitations/send_representative_reset_password.css',
  # Street Addresses
  'street_addresses/main.css',
  'street_addresses/modals.css',
  # Tables
  'tables/main.css',
  'tables/main.js',
  'tables/modals.css'
]