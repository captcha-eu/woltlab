<?php

namespace wcf\system\captchaeu;

use wcf\system\exception\UserInputException;
use wcf\system\io\HttpFactory;
use wcf\system\SingletonFactory;
use wcf\system\WCF;
use wcf\util\JSON;

/**
 * Captcha.eu Validation Handler
 *
 * @author		Captcha.eu
 * @copyright	Captcha.eu
 * @license		GNU Library General Public License version 2 <https://opensource.org/license/lgpl-2-0/>
 * @package		WoltLabSuite\Core\System\CaptchaEU
 */
class CaptchaEUHandler extends SingletonFactory {

	/**
	 * Validates the given solution, throws various exceptions if solution not supplied or invalid
	 *
	 * @param	string	$solution
	 * @throws	UserInputException
	 */
	public function validate($solution) {

		// make sure solution is supplied & not empty
		if (empty($solution)) {
			throw new UserInputException('captchaeuSolution', '101');
		}

		// validation endpoint where the solution is getting validated
		$validationEndpoint = CAPTCHAEU_HOST . '/validate';

		// initialize http client
		$httpClient = HttpFactory::makeClient([
			'connect_timeout' => 10
		]);

		try {

			// send request to captcha.eu service host
			$res = $httpClient->request('POST', $validationEndpoint, [
				'body' => $solution,
				'headers' => [
					'Rest-Key' => CAPTCHAEU_RESTKEY,
					'Content-Type' => 'application/json'
				]
			]);

			// obtain response
			$resBody = $res->getBody();

			// decode json response
			$data = (object) JSON::decode($resBody);

			// if failed => throw exception
			if (!$data->success) {
				throw new UserInputException('captchaeuSolution', '102');
			}
		} catch (\GuzzleHttp\Exception\ClientException $e) {

			// check response status code
			if($e->getResponse()->getStatusCode() == 403) {
				// 403 => throw exception
				throw new UserInputException('captchaeuSolution', '301');
			}
		} catch (\Exception $e) {
			// if UserInputException => throw
			if ($e instanceof UserInputException) {
				throw $e;
			}

			// log but continue
			\wcf\functions\exception\logThrowable($e);
		}

		// get session
		$session = WCF::getSession();

		// register var
		$session->register('captchaeu-done', true);
	}
}
