package tools.vlab.kberry.app.dashboard;

public class Value {
    ValueType type;
    String from;
    String to;
    String value;

    public Value(ValueType type, String from, String to, String value) {
        this.type = type;
        this.from = from;
        this.to = to;
        this.value = value;
    }

    public Value() {
    }

    public ValueType getType() {
        return type;
    }

    public void setType(ValueType type) {
        this.type = type;
    }

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
