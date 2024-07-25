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
	public $tcp; // boll
	public $ws; // boll
	public $wss; // boll
	public $country; // string
	public $countryCode; // string
	public $isp; // string
	public $hostsData; // string
	public $data; // string
	public $city;

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
	}
}
?>