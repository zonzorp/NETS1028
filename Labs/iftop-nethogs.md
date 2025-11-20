# Lab: Introduction to `iftop` and `nethogs` for Network Monitoring

This lab will guide you through installing, running, and analyzing network activity using the tools **iftop** and **nethogs**.  
Follow each step carefully and record your observations where prompted.


## Objectives

By the end of this lab, you will be able to:

- Install and use `iftop` and `nethogs`  
- Monitor network traffic by connection and by process  
- Identify bandwidth-heavy applications and hosts  
- Compare the two monitoring tools and understand when to use each

## Part 1 — Preparing Your System

### 1. Identify Network Interface

Run:

```bash
ip a
```
Identify your active network interface (e.g., eth0, wlan0, enp0s3).

## Part 2 — Installing the Tools

1. Install iftop
```bash
sudo apt update
sudo apt install iftop
```

2. Install nethogs
```bash
sudo apt install nethogs
```

## Part 3 — Using iftop

1. Start iftop

Run:
```bash
sudo iftop -i <your-interface>
```
Example:
```bash
sudo iftop -i eth0
```
2. Observe the Interface

Answer the following:
	•	Which remote hosts are you connected to?
	•	Which host had the highest bandwidth usage?
	•	What was the approximate highest observed bandwidth?

3. Test Scenario
	1.	Open a new browser tab and load a media-heavy site (YouTube, Twitch, etc.).
	2.	Watch the iftop window for changes.
	3.	Press t, n, and N to toggle different display modes.

Consider what changed as you toggled modes.

## Part 4 — Using nethogs

1. Start nethogs

Run:
```bash
sudo nethogs <your-interface>
```
1. Observe Network Usage by Process

Consider:
	•	Which process is using the most bandwidth?
	•	Is the traffic upload, download, or both?

1.	In another terminal, run a download command:
```bash
wget https://speed.hetzner.de/100MB.bin
```
1.	Watch how nethogs displays the process.

## Part 5 — Compare the Tools

Compare based on your experience:

Which tool shows per-host traffic?		
Which tool shows per-process traffic?		
Which tool was more helpful for identifying what you were connected to?		
Which tool was more helpful for identifying which program was using bandwidth?		

## Part 6 — Challenge Exercises

Exercise 1: Identify Background Traffic

Use iftop to identify any unexpected or unknown hosts communicating with your system.

Exercise 2: Monitor a Specific Application

Start an application such as apt, a browser, or Steam, and track its bandwidth in nethogs.

Exercise 3: Log Network Activity

Use iftop in batch mode:
```bash
sudo iftop -i <interface> -t > iftop_log.txt
```
Review the log file to examine connections over time.

⸻

Lab Completion

You have completed the introductory lab on network monitoring with iftop and nethogs.

⸻


