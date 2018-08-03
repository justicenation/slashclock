/**
 * An Apex job which may be requested for execution through creation
 * of an Apex Job Request record
 */
public interface Requestable {

    void execute(Database.BatchableContext context);
}