class InvitationPdf < Prawn::Document

  def header
    logopath =  "#{Rails.root}/app/assets/images/logo-header-mailer.png"
    image logopath, width: 522, height: 100, position: :center
  end

  def content(name, birth, code)
    move_down 50
    text_box "Dear, #{name}", at: [35, 580], width: 452, size: 10
    text_box "You have been invited to access your health records in your EHR 1 Patient Portal.", at: [35, 550], size: 10
    text_box "View upcoming appointment, care notes from your recent appointment(s), send a secure message the practice or your provider, and more!", at: [35, 520], width: 452, size: 10
    text_box "To setup your account, first make sure to contact your practice for a Security Access Code:", at: [35, 470], size: 10
    stroke do
      stroke_color "41B6A6"
      rounded_rectangle [100, 430], 320, 80, 5
    end
    fill_color "000000"
    text_box "#{code}", at: [240, 395], size: 14
    text_box "Then, go to the link below and follow the instructions on the page to complete setting up your Patient Portal account.", at: [35, 320], width: 452, size: 10
    text_box "#{Rails.application.secrets.full_domain_name}/users/sign_in", at: [35, 265], width: 452, align: :center, size: 12
    text_box "Sincerely,", at: [35, 220], size: 10
    text_box "EHR1 Team", at: [35, 190], size: 10
  end

  def footer
    stroke do
      stroke_color "41B6A6"
      fill_color "41B6A6"
      fill_polygon [10, 13], [10, 33], [20, 33], [20, 13], [10, 13]
      fill_polygon [530, 13], [530, 33], [520, 33], [520, 13], [530, 13]
      fill_and_stroke_rounded_polygon 10, [11, 3], [11, 32], [529, 32],
                [529, 3], [11, 3], [11, 32]
    end
    fill_color "FFFFFF"
    text_box "© 2015 EHR One, LLC", at: [50, 21], size: 10
  end

  def initialize(name, birth, code)
    super()
    self.line_width = 2
    font_families.update(
      "Verdana": {
        bold: "/home/deployer/new-development/app/assets/fonts/timesnewromanb.ttf",
        italic: "/home/deployer/new-development/app/assets/fonts/timesnewromani.ttf",
        normal: "/home/deployer/new-development/app/assets/fonts/timesnewr.ttf"
    })

    stroke_color "979797"
    stroke do
      rounded_rectangle [9, 721], 522, 720, 13
      header
    end
    content(name, birth, code)
    footer
  end
end
