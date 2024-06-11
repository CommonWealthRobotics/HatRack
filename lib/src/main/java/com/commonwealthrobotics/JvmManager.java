package com.commonwealthrobotics;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import javafx.application.Platform;
import javafx.scene.control.ProgressBar;

public class JvmManager {

	public static String getCommandString(String project, String repo, String version,String downloadJsonURL,long sizeOfJson, ProgressBar progress,String bindir) throws Exception {
		
		URL url = new URL(downloadJsonURL);
		URLConnection connection = url.openConnection();
		InputStream is = connection.getInputStream();
		ProcessInputStream pis = new ProcessInputStream(is, (int) sizeOfJson);
		pis.addListener(new Listener() {
			@Override
			public void process(double percent) {
				Platform.runLater(() -> {
					progress.setProgress(percent);
				});
			}
		});
		File folder = new File(bindir + version + "/");
		File exe = new File(bindir + version + "/jvm.json"  );

		if (!folder.exists() || !exe.exists() || sizeOfJson != exe.length()) {
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
		}
		
		
		return "";
	}
}
