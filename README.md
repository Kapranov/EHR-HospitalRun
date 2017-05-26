### Dec 2016 Oleg G.Kapranov

EHR-Dental Doctor Portal Release - Stable
=========================================

By considering this equation e = mc2

> “Errors = (More Code)2”


Ruby on Rails
-------------

> This application requires:

- Ruby  2.3.1
- Rails 4.2.7
- gem rethinkdb 2.3.0
- pip rethinkdb 2.3.0.post6
- RethinkDB 2.3.5~0jessie
- DoseSpot
- Snomed CT v20160301
- Duo security
- Twilio
- Medical Plus
- Loinc

> Rethinkdb Cluster

- server1 ``http://dev.ehr1.us:8000/``
- server2 ``https://test.ehr1.us``
- server3 ``https://dental.ehr1.us``
- server4 ``https://prod1.ehr1.us``

Getting Started
---------------

- https://test.ehr1.us   production
- https://dental.ehr1.us production
- https://prod1.ehr1.us  production
- http://dev.ehr.us:8000 development
- http://dev.ehr.us:9000 development api
- http://dev.ehr.us:1080 development mailer client
- http://dev.ehr.us:8080 data exployer rethinkdb
- http://dev.ehr.us:8081 data exployer node.js mongodb admin@pass
- http://dev.ehr.us:8082 data exployer node.js snomed
- http://dev.ehr.us:3000 data api node.js snomed

> The dump files

- ``area_codes``
- ``languages``
- ``loinc_comments``
- ``loincs``
- ``nobrainer_index_meta``
- ``nobrainer_locks``
- ``procedure_codes``
- ``v20160301``
- ``vaccines``

> The state area codes

[http://www.50states.com/areacodes/](State Area Codes)

```
  Alabama Area Codes:         205 - 251 - 256 - 334
  Alaska Area Codes:          907
  Arizona Area Codes:         480 - 520 - 602 - 623 - 928
  Arkansas Area Codes:        501 - 870
  California Area Codes:      209 - 213 - 310 - 323 - 408 - 415 - 510 -
                              530 - 559 - 562 - 619 - 626 - 650 - 661 -
                              707 - 714 - 760 - 805 - 818 - 831 - 858 -
                              909 - 916 - 925 - 949
  Colorado Area Codes:        303 - 719 - 720 - 970
  Connecticut Area Codes:     203 - 860
  Delaware Area Codes:        302
  Florida Area Codes:         305 - 321 - 352 - 386 - 407 - 561 - 727 -
                              754 - 772 - 786 - 813 - 850 - 863 - 904 -
                              941 - 954
  Georgia Area Codes:         229 - 404 - 478 - 678 - 706 - 770 - 912
  Hawaii Area Codes:          808
  Idaho Area Codes:           208
  Illinois Area Codes:        217 - 309 - 312 - 618 - 630 - 708 - 773 -
                              815 - 847
  Indiana Area Codes:         219 - 260 - 317 - 574 - 765 - 812
  Iowa Area Codes:            319 - 515 -563 - 641 - 712
  Kansas Area Codes:          316 - 620 - 785 - 913
  Kentucky Area Codes:        270 - 502 - 606 - 859
  Louisiana Area Codes:       225 - 318 - 337 - 504 - 985
  Maine Area Codes:           207
  Maryland Area Codes:        240 - 301 - 410 - 443
  Massachusetts Area Codes:   339 - 351 - 413 - 508 - 617 - 774 - 781 -
                              857 - 978
  Michigan Area Codes:        231 - 248 - 269 - 313 - 517 - 586 - 616 -
                              734 - 810 - 906 - 989
  Minnesota Area Codes:       218 - 320 - 507 - 612 - 651 - 763 - 952
  Mississippi Area Codes:     228 - 601 - 662
  Missouri Area Codes:        314 - 417 - 573 - 636 - 660 - 816
  Montana Area Codes:         406
  Nebraska Area Codes:        308 - 402
  Nevada Area Codes:          702 - 775
  New Hampshire Area Codes:   603
  New Jersey Area Codes:      201 - 609 - 732 - 856 - 908 - 973
  New Mexico Area Codes:      505
  New York Area Codes:        212 - 315 - 347 - 516 - 518 - 607 - 631 -
                              646 - 716 - 718 - 845 - 914 - 917
  North Carolina Area Codes:  252 - 336 - 704 - 828 - 910 - 919 - 980
  North Dakota Area Codes:    701
  Ohio Area Codes:            216 - 234 - 330 - 419 - 440 - 513 - 614 -
                              740 - 937
  Oklahoma Area Codes:        405 - 580 - 918
  Oregon Area Codes:          503 - 541 - 971
  Pennsylvania Area Codes:    215 - 267 - 412 - 484 - 570 - 610 - 717 -
                              724 - 814 - 878
  Rhode Island Area Codes:    401
  South Carolina Area Codes:  803 - 843 - 864
  South Dakota Area Codes:    605
  Tennessee Area Codes:       423 - 615 - 731 - 865 - 901 - 931
  Texas Area Codes:           210 - 214 - 254 - 281 - 361 - 409 - 469 -
                              512 - 682 - 713 - 806 - 817 - 830 - 832 -
                              903 - 915 - 936 - 940 - 956 - 972 - 979
  Utah Area Codes:            435 - 801
  Vermont Area Codes:         802
  Virginia Area Codes:        276 - 434 - 540 - 571 - 703 - 757 - 804
  Washington Area Codes:      206 - 253 - 360 - 425 - 509
  West Virginia Area Codes:   304
  Wisconsin Area Codes:       262 - 414 - 608 - 715 - 920
  Wyoming Area Codes:         307
```

> USA Address by example #1

```
  517 SW 4th Ave, Ste 2
  Portland, OR 97204
  http://maps.google.com/maps?q=517+SW+4th+Ave,+Ste+2,+Portland,+OR+97204&hl=en&t=m&z=17&f=d
  Phone: 415.488.5324
```

> USA Address by example #2

```
  Dot Net Factory, LLC
  21182 Winding Brook Sq.
  Ashburn, VA 20147
```

> USA Address by example #3

```
  Address: 156 E Dana St, Mountain View, CA 94041, United States
  Phone:+1 650-605-8385
```

> Change Trial period for view modal block with gradient

```bash
  Provider.last.update(trial: 19)
  Provider.last.update(trial: 4)
```

> The Mail messages

```bash
  InvitationMailer.send_invitation('FirstName', 'LastName', '123456', 'email@email.com').deliver_now RAILS_ENV=production
  Devise::Mailer.confirmation_instructions(User.first, "faketoken").deliver_now
  Devise::Mailer.reset_password_instructions(User.first, "faketoken").deliver_now
  Devise.token_generator.generate(User, :confirmation_token)
  Devise.token_generator.generate(User, :reset_password_token)
```

> Seeds for different environments

[https://github.com/james2m/seedbank](Seedbank gives your Rails seed data a little structure)

[https://archive.dennisreimann.de/blog/seeds-for-different-environments/](Seeds for ENV)

Documentation and Support
-------------------------

- Snomed CT access for get update archives

``wget "https://download.nlm.nih.gov/mlb/utsauth/USExt/SnomedCT_RF2Release_US1000124_20160301.zip"``

``wget "htpps://ehrone:Ehrone123!@download.nlm.nih.gov/mlb/utsauth/USExt/SnomedCT_RF2Release_US1000124_20160301.zip"``

- Snomed CT Browser

``http://browser.ihtsdotools.org/``

> The enviroments of the application

```ruby
  if %w(development production).include?(Rails.env)
    # do something
  end
```

> CSR file is the Certificate Signing Request.
> Buy the SSL on Godaddy Inc.

``http://nginx.groups.wuyasea.com/articles/how-to-setup-godaddy-ssl-certificate-on-nginx/2``

```bash
  cat 33d2f437725c2a17.crt gd_bundle-g2-g1.crt > dentalehr1us.crt
```

```bash
  openssl x509 -req -in dentalehr1us.csr -signkey dentalehr1us.key -out dentalehr1us.crt
```

> Devise extensions

* [https://github.com/plataformatec/devise/wiki/Extensions](List of 3rd party Devise extensions)
* [https://github.com/phatworx/devise_security_extension](An enterprise security extension for Devise)
* [https://github.com/j-mcnally/devise_account_expireable](Devise Account Expireable)
* [https://github.com/plataformatec/devise/blob/master/lib/devise/models/trackable.rb](Devise Trackable)
* [http://stackoverflow.com/questions/30069670/rails-4-geocoder-with-devise](Rails 4 : Geocoder with Devise)

> jsPDF packed for Rails asset pipeline

[https://github.com/matixmatix/jspdf-rails](jsPDF is a library for creating PDF files in client-side JavaScript.)

Issues
-------------

Similar Projects
----------------

Contributing
------------

Credits
-------

License
-------

### 29 Apr 2017 Oleg G.Kapranov
