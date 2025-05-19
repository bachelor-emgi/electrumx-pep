<?php

namespace App;

class Peer
{
	public $host; // string
	public $ip; // string
	public $ipv6; // bool
	public $tor; // bool
	public $status; // string
	public $client; // string
	public $ssl; // bool
	public $tcp; // bool
	public $ws; // bool
	public $wss; // bool
	public $country; // string
	public $countryCode; // string
	public $isp; // string
	public $hostsData; // string
	public $data; // string
	public $city;
	public $ssl_valid;

	function __construct($peer)
	{
		$this->data = $peer;
		$this->host = htmlspecialchars($peer['host']);
		$this->ip = checkIp($peer['ip_addr']);
		$this->ipv6 = checkIfIpv6($this->ip);
		$this->status = htmlspecialchars($peer['status']);
		$this->client = htmlspecialchars($peer['features']['server_version']);
		$this->hostsData = getHostsData($peer['features']['hosts']);
		$this->tor = $this->hostsData['tor'];
		$this->ssl = $this->hostsData['ssl'];
		$this->tcp = $this->hostsData['tcp'];

		// Check SSL certificate ONLY if the peer supports SSL
		$this->ssl_valid = false;
		if ($this->ssl && $this->host) {
			$this->ssl_valid = $this->validateSslCert($this->host);
		}
	}

	// Validate SSL certificate for a host (returns true/false)
	private function validateSslCert($host, $port = 50002, $timeout = 3)
	{
		$context = stream_context_create([
			"ssl" => [
				"capture_peer_cert" => true,
				"verify_peer" => true,
				"verify_peer_name" => true,
				"allow_self_signed" => false,
			]
		]);
		$client = @stream_socket_client(
			"ssl://{$host}:{$port}",
			$errno,
			$errstr,
			$timeout,
			STREAM_CLIENT_CONNECT,
			$context
		);
		if ($client === false) {
			return false;
		}
		$params = stream_context_get_params($client);
		if (!isset($params["options"]["ssl"]["peer_certificate"])) {
			return false;
		}
		$cert_resource = $params["options"]["ssl"]["peer_certificate"];
		$cert_info = openssl_x509_parse($cert_resource);
		if (!$cert_info) {
			return false;
		}
		$now = time();
		return ($now >= $cert_info['validFrom_time_t'] && $now <= $cert_info['validTo_time_t']);
	}
}
?>