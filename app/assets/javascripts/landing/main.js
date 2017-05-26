//= require application
//= require ui/main
//= require any-login/any-login
//= require select2-custom/select2-custom

$(document).ready(function(){
	LandingProviderPatientContentChangesController = function() {
		var btn_container, provider_btn, patient_btn;
		var register_container, sign_in_container;

		this.initialize = function() {
			main_title = $('#main_title');
			btn_container = $('#portal_types');
			provider_btn = $('#provider_btn');
			patient_btn = $('#patient_btn');
			register_container = $('#register_container');
			sign_in_container = $('#sign_in_container');

			provider_btn.click(function(e) {
				e.preventDefault();

				btn_container.find('span').removeClass('active');
				$(this).addClass('active');

				main_title.html("<h1>Your New EHR is just a few clicks away.</h1>\
          							 <p>Want an EHR that is easy to use, affordable, and still has all of the practice management functions you need for your busy practice?</p>\
          							 <p>Then you've come to the right place. With an outstanding support team ready to help get you setup, you'll be charting before you know it.</p>");
				
				register_container.removeClass('collapse');

				sign_in_container.attr('class', 'col-lg-4 col-md-4 col-sm-4 col-lg-offset-4 col-md-offset-4 col-sm-offset-4 block');
				sign_in_container.find('.content').html("<h4 class='title'>Already registered?</h4>\
        <h5 class='sub-title'>Sign in now</h5>");
        sign_in_container.find('.content-bottom').remove();
			});

			patient_btn.click(function(e) {
				e.preventDefault();

				btn_container.find('span').removeClass('active');
				$(this).addClass('active');
				
				main_title.html("<h1>Welcome to your Patient Portal!</h1>\
				<h1>Your Health Records, whenever and whever you need them.</h1>\
        <p>Setup or Sign In to your Patient Portal today to view your health records, send a secure message to your doctor, schedule an appointment online, and more.</p>");
				
				register_container.addClass('collapse');
				
				sign_in_container.attr('class', 'col-lg-8 col-md-8 col-sm-8 col-lg-offset-2 col-md-offset-2 col-sm-offset-2 block');
				sign_in_container.find('.content').html("\
				<h4 class='title'>Sign in to your Patient Portal!</h4>");
				$("<div class='content content-bottom'>\
				<h5 class='sub-title'>Don't have a Patient Portal account?</h5>\
				<h5 class='sub-title'>Contact your doctor's office and request a Patient Portal invite email o setup your Patient Portal account today!</h5>\
				</div>").insertAfter(sign_in_container.find('.button-landing:last-child'));
			});
		}
	}

	var landingProviderPatientContentChangesController = new LandingProviderPatientContentChangesController();
	landingProviderPatientContentChangesController.initialize();
});