package tools.vlab.kberry.app.commands;

import io.vertx.core.Future;
import tools.vlab.kberry.core.PositionPath;
import tools.vlab.kberry.server.settings.Settings;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

public class LogicIdStore implements Settings<String> {

    /**
     * Key: PositionPath.getId()
     * Value: LogicId (String)
     */
    private final Map<String, String> store = new ConcurrentHashMap<>();

    @Override
    public Future<String> getSettingAsync(PositionPath path) {
        return Future.succeededFuture(store.get(path.getId()));
    }

    @Override
    public Future<Void> setSettingAsync(PositionPath path, String value) {
        store.put(path.getId(), value);
        return Future.succeededFuture();
    }

    @Override
    public Optional<String> getSetting(PositionPath path) {
        return Optional.ofNullable(store.get(path.getId()));
    }
}