package com.commonwealthrobotics;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Type;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.compress.archivers.examples.Archiver;
import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.compress.archivers.tar.TarUtils;
import org.apache.commons.compress.compressors.gzip.GzipCompressorInputStream;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import javafx.application.Platform;
import javafx.scene.control.ProgressBar;

public class JvmManager {

	public static String getCommandString(String project, String repo, String version, String downloadJsonURL,
			long sizeOfJson, ProgressBar progress, String bindir) throws Exception {

		File exe = download(version, downloadJsonURL, sizeOfJson, progress, bindir, "jvm.json");
		Type TT_mapStringString = new TypeToken<HashMap<String, Object>>() {
		}.getType();
		// chreat the gson object, this is the parsing factory
		Gson gson = new GsonBuilder().disableHtmlEscaping().setPrettyPrinting().create();
		String jsonText = Files.readString(exe.toPath());

		HashMap<String, Object> database = gson.fromJson(jsonText, TT_mapStringString);
		String key = "UNKNOWN";
		if (LatestFromGithubLaunchUI.isLin()) {
			if (LatestFromGithubLaunchUI.isArm()) {
				key = "Linux-aarch64";
			} else {
				key = "Linux-x64";
			}
		}

		if (LatestFromGithubLaunchUI.isMac()) {
			if (LatestFromGithubLaunchUI.isArm()) {
				key = "Mac-aarch64";
			} else {
				key = "Mac-x64";
			}
		}
		if (LatestFromGithubLaunchUI.isWin()) {
			if (LatestFromGithubLaunchUI.isArm()) {
				key = "UNKNOWN";
			} else {
				key = "Windows-x64";
			}
		}
		Map<String, Object> vm = (Map<String, Object>) database.get(key);
		String baseURL = vm.get("url").toString();
		String type = vm.get("type").toString();
		String name = vm.get("name").toString();
		List<String> jvmargs = null;
		Object o = vm.get("jvmargs");
		if (o != null)
			jvmargs = (List<String>) o;
		else
			jvmargs = new ArrayList<String>();
		String jvmURL = baseURL + name + "." + type;
		File jvmArchive = download("", jvmURL, 185000000, progress, bindir, name + "." + type);
		File dest = new File(bindir+name);
		if(!dest.exists()) {
			if (type.toLowerCase().contains("zip")) {
				unzip(jvmArchive, bindir);
			}
			if (type.toLowerCase().contains("tar.gz")) {
				untar(jvmArchive, bindir);
			}
		}else {
			System.out.println("Not extraction, VM exists "+dest.getAbsolutePath());
		}
		String cmd = bindir + name + "/bin/java" + (LatestFromGithubLaunchUI.isWin() ? ".exe" : "") + " ";
		for (String s : jvmargs) {
			cmd += s + " ";
		}
		return cmd + " -jar ";
	}

	private static void unzip(File zip, String dir) {

	}

	private static void untar(File tarFile, String dir) throws Exception {
		File dest = new File(dir);
		dest.mkdir();
		TarArchiveInputStream tarIn = null;

		tarIn = new TarArchiveInputStream(
				new GzipCompressorInputStream(new BufferedInputStream(new FileInputStream(tarFile))));
		TarArchiveEntry tarEntry = tarIn.getNextTarEntry();
		// tarIn is a TarArchiveInputStream
		while (tarEntry != null) {// create a file with the same name as the tarEntry
			File destPath = new File(dest.toString() + System.getProperty("file.separator") + tarEntry.getName());
			//System.out.println("working: " + destPath.getCanonicalPath());
			if (tarEntry.isDirectory()) {
				destPath.mkdirs();
			} else {
				destPath.createNewFile();
				FileOutputStream fout = new FileOutputStream(destPath);
				byte[] b = new byte[(int) tarEntry.getSize()];
				tarIn.read(b);
				fout.write(b);
				fout.close();
				int mode = tarEntry.getMode();
				b= new byte[5];
				TarUtils.formatUnsignedOctalString(mode, b, 0, 4);
				if(bits(b[1]).endsWith("1")) {
					destPath.setExecutable(true);
				}
//				if(destPath.getName().endsWith("javac")) {
//					System.out.println("Java file is"+destPath);
//					//System.out.println(mode);
//					System.out.println("Bytes are "+bits(b[0])+","+bits(b[1])+","+bits(b[2])+","+bits(b[3]));
//				}
//				if(destPath.getName().endsWith("zip")) {
//					System.out.println("zip file is"+destPath);
//					//System.out.println(mode);
//					System.out.println("Bytes are "+bits(b[0])+","+bits(b[1])+","+bits(b[2])+","+bits(b[3]));
//
//				}
			}
			tarEntry = tarIn.getNextTarEntry();
		}
		tarIn.close();
	}
	private static String bits(byte b) {
		return String.format("%6s", Integer.toBinaryString(b & 0xFF)).replace(' ', '0');
	}

	private static File download(String version, String downloadJsonURL, long sizeOfJson, ProgressBar progress,
			String bindir, String filename) throws MalformedURLException, IOException, FileNotFoundException {
		URL url = new URL(downloadJsonURL);
		URLConnection connection = url.openConnection();
		InputStream is = connection.getInputStream();
		ProcessInputStream pis = new ProcessInputStream(is, (int) sizeOfJson);
		pis.addListener(new Listener() {
			@Override
			public void process(double percent) {
				System.out.println("Download percent " + percent);
				Platform.runLater(() -> {
					progress.setProgress(percent);
				});
			}
		});
		File folder = new File(bindir + version + "/");
		File exe = new File(bindir + version + "/" + filename);

		if (!folder.exists() || !exe.exists()) {
			System.out.println("Start Downloading " + filename);
			folder.mkdirs();
			exe.createNewFile();
			byte dataBuffer[] = new byte[1024];
			int bytesRead;
			FileOutputStream fileOutputStream = new FileOutputStream(exe.getAbsoluteFile());
			while ((bytesRead = pis.read(dataBuffer, 0, 1024)) != -1) {
				fileOutputStream.write(dataBuffer, 0, bytesRead);
			}
			fileOutputStream.close();
			pis.close();
			System.out.println("Finished downloading " + filename);
		} else {
			System.out.println("Not downloadeing, it existst " + filename);
		}
		return exe;
	}
}