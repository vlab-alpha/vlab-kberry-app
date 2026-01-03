package tools.vlab.smart.frontend;

import android.content.Context;
import android.net.Uri;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.rtsp.RtspMediaSource;
import androidx.media3.ui.PlayerView;
import androidx.media3.exoplayer.DefaultRenderersFactory;
import androidx.media3.exoplayer.RenderersFactory;
import androidx.media3.exoplayer.mediacodec.MediaCodecSelector;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import android.content.ActivityNotFoundException;

import android.content.Intent;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;


public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "app.channel.shared.data";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        flutterEngine.getPlatformViewsController().getRegistry()
                .registerViewFactory("rtsp_player", new RtspPlayerFactory());

        // MethodChannel zum Öffnen der Reolink App
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("openSipgate")) {
                        try {
                            Intent intent = new Intent();
                            intent.setClassName("com.zoiper.android.app", "com.zoiper.android.ui.MainActivity");
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            startActivity(intent);
                            result.success("Zoiper geöffnet");
                        } catch (ActivityNotFoundException e) {
                            result.error("APP_NOT_FOUND", "Zoiper App nicht installiert", null);
                        }
                    } else if (call.method.equals("openReolinkApp")) {
                        RtspPlayerView.pauseAllPlayers();
                        Intent intent = new Intent();
                        intent.setClassName("com.mcu.reolink", "com.android.bc.login.WelcomeActivity");
                        if (intent != null) {
                            startActivity(intent);
                            result.success("Reolink geöffnet");
                        } else {
                            result.error("APP_NOT_FOUND", "Reolink App nicht installiert", null);
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }
}

class RtspPlayerFactory extends PlatformViewFactory {
    public RtspPlayerFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    @NonNull
    @Override
    @SuppressWarnings("unchecked")
    public PlatformView create(@NonNull Context context, int viewId, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        String url = (String) params.get("url");
        return new RtspPlayerView(context, url);
    }
}

class RtspPlayerView extends FrameLayout implements PlatformView {
    private final PlayerView playerView;
    private final ExoPlayer player;
    private static final List<ExoPlayer> allPlayers = new ArrayList<>();

    public RtspPlayerView(@NonNull Context context, String url) {
        super(context);

        playerView = new PlayerView(context);
        //addView(playerView, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        DefaultRenderersFactory renderersFactory = new DefaultRenderersFactory(context)
                .setExtensionRendererMode(DefaultRenderersFactory.EXTENSION_RENDERER_MODE_OFF)
                .setEnableDecoderFallback(true)
                .setMediaCodecSelector(MediaCodecSelector.DEFAULT);
        player = new ExoPlayer.Builder(context)
                .setRenderersFactory(renderersFactory)
                .build();
        player.addListener(new Player.Listener() {
            @Override
            public void onPlayerError(@NonNull PlaybackException error) {
                Log.e("RTSP", "Fehler beim Abspielen: " + error.getMessage());
            }
        });
        playerView.setPlayer(player);

        allPlayers.add(player);

        // **Hier der Java-kompatible MediaItem-Aufruf**
        MediaItem mediaItem = MediaItem.fromUri(Uri.parse(url));

        RtspMediaSource.Factory factory = new RtspMediaSource.Factory();
        player.setMediaSource(factory.createMediaSource(mediaItem));

        player.prepare();
        player.play();
    }

    @Override
    public View getView() {
        return playerView;
    }

    @Override
    public void dispose() {
        player.release();
        allPlayers.remove(player);
    }

    public static void pauseAllPlayers() {
        for (ExoPlayer p : allPlayers) {
            if (p.isPlaying()) {
                p.pause();
            }
        }
    }
}