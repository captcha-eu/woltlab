{* Captcha.eu adaption of WoltLab/WCF /templates/recaptcha.tpl *}
<section class="section">
	{assign var="captchaeuContainerID" value=true|microtime|sha1}
	<dl class="{if $errorField|isset && $errorField == 'captchaeuSolution'}formError{/if}">
		<dt></dt>
		<dd>
			<div id="captchaeuContainer{$captchaeuContainerID}"></div>
			{if (($errorType|isset && $errorType|is_array && $errorType[captchaeuSolution]|isset) || ($errorField|isset && $errorField == 'captchaeuSolution'))}
				{if $errorType|is_array && $errorType[captchaeuSolution]|isset}
					{assign var='__errorType' value=$errorType[captchaeuSolution]}
				{else}
					{assign var='__errorType' value=$errorType}
				{/if}
				<small class="innerError">
					{if $__errorType == 'empty'}
						{lang}wcf.global.form.error.empty{/lang}
					{else}
						{lang}wcf.captchaeu.error.captchaeuSolution.{$__errorType}{/lang}
					{/if}
				</small>
			{/if}
		</dd>
	</dl>
	<script data-relocate="true">
		if (!WCF.captchaeuHandler) {
			WCF.captchaeuHandler = {
				queue: [],
				callbackCalled: false,
				mapping: { }
			};

			// this needs to be in global scope
			function captchaEUCallback() {
				// KROT SETUP
				KROT.setup('{CAPTCHAEU_PUBLICKEY|encodeJS}');
				KROT.KROT_HOST = '{CAPTCHAEU_HOST|encodeJS}';

				var containerId;
				WCF.captchaeuHandler.callbackCalled = true;

				// clear queue
				while (config = WCF.captchaeuHandler.queue.shift()) {
					(function (config) {
						var containerId = config.container;

						// require utils
						require(['Dom/Traverse', 'Dom/Util'], function (DomTraverse, DomUtil) {
							// get container
							var container = elById(containerId);

							// AJAX Captcha
							if (config.ajaxCaptcha) {
								WCF.System.Captcha.addCallback(config.ajaxCaptcha, function() {
									// promise resolved => return solution
									return KROT.getSolution().then(function(solution) {
										return {
											'captcha_at_solution': JSON.stringify(solution)
										};
									});
								});
							} else {
								// get form by container
								var form = DomTraverse.parentByTag(container, 'FORM');

								// store clicked submit button
								var submitClicked = undefined;
								elBySelAll('input[type="submit"]', form, function (button) {
									button.addEventListener('click', function (event) {
										submitClicked = button;
									});
								});

								var submitListener = function (event) {
									// prevent further
									event.preventDefault();

									// disable submit button
									submitClicked.disabled = true;

									// get solution
									KROT.getSolution().then((solution) => {
										// create hidden input & set value
										var input = document.createElement('input');
										input.setAttribute('type', 'hidden');
										input.setAttribute('name', 'captcha_at_solution');
										input.setAttribute('value', JSON.stringify(solution));

										// add to form
										form.appendChild(input);

										// remove eventlistener
										form.removeEventListener('submit', submitListener);

										// enable submit button
										submitClicked.disabled = false;

										// trigger click
										submitClicked.click();
									});
								}

								// register form submit handler
								form.addEventListener('submit', submitListener);
							}
						});
					})(config);
				}
			}
		}

		// add captcha to queue
		WCF.captchaeuHandler.queue.push({
			container: 'captchaeuContainer{$captchaeuContainerID}'
			{if $ajaxCaptcha|isset && $ajaxCaptcha}
			, ajaxCaptcha: '{$captchaID}'
			{/if}
		});

		// trigger callback if available
		if (WCF.captchaeuHandler.callbackCalled) {
			setTimeout(captchaEUCallback, 1);
		}

		// ensure Captcha.eu SDK is loaded
		if (!window.KROT) {
			$.getScript('{CAPTCHAEU_HOST|encodeJS}/sdk.js', function() {
				captchaEUCallback();
			});
		}
	</script>
</section>
