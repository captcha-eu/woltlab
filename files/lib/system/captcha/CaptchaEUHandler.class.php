<?php

namespace wcf\system\captcha;

use wcf\system\WCF;

/**
 * Captcha.eu Handler Class
 *
 * @author		Captcha.eu
 * @copyright	Captcha.eu
 * @license		GNU Library General Public License version 2 <https://opensource.org/license/lgpl-2-0/>
 * @package		WoltLabSuite\Core\System\Captcha
 */
class CaptchaEUHandler implements ICaptchaHandler {

	/**
	 * Captcha.eu Solution parameter
	 * @var	string
	 */
	private $solutionParam = 'captcha_at_solution';

	/**
	 * Captcha.eu Solution
	 * @var	string
	 */
	public $solution = '';

	/**
	 * @inheritDoc
	 */
	public function getFormElement() {
		// get template
		$template = WCF::getTPL();

		// get session
		$session = WCF::getSession();

		// skip output if captcha done
		if ($session->getVar('captchaeu-done')) {
			return '';
		}

		// fetch captchaeu
		return $template->fetch('captchaeu');
	}

	/**
	 * @inheritDoc
	 */
	public function isAvailable(): bool {
		// ensure captcha.eu settings are set
		$captchaEUSettingsSet = (CAPTCHAEU_PUBLICKEY && CAPTCHAEU_RESTKEY && CAPTCHAEU_HOST);

		// workaround
		$forceAvailable = RecaptchaHandler::$forceIsAvailable;

		return $forceAvailable || $captchaEUSettingsSet;
	}

	/**
	 * @inheritDoc
	 */
	public function readFormParameters(): void {
		// if post field is set
		if (isset($_POST[$this->solutionParam])){
			// set solution by POST var
			$this->solution = $_POST[$this->solutionParam];
		}
	}

	/**
	 * @inheritDoc
	 */
	public function reset(): void {
		// get session
		$session = WCF::getSession();

		// unregister var
		$session->unregister('captchaeu-done');
	}

	/**
	 * @inheritDoc
	 */
	public function validate(): bool {
		// get session
		$session = WCF::getSession();

		// ensure that captcha is done
		if ($session->getVar('captchaeu-done')) {
			return false;
		}

		// validate via handler
		$captchaEUHandler = \wcf\system\captchaeu\CaptchaEUHandler::getInstance();
		$captchaEUHandler->validate($this->solution);

		return true;
	}
}
