/**
 * @description       : 
 * @author            : RKA
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : RKA
**/
public without sharing class UtilJSON {

    /**
    * @description clear null value in json list
    * @author RKA | 06-28-2024 
    * @param jsonString 
    * @return String 
    **/
    public static String removeNullsAndEmptyValues(String jsonString) {
        // Parse JSON string to a map
        Map<String,Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        // Recursively remove null or empty values
        jsonMap = cleanJsonMap(jsonMap);
        
        // Serialize the map back to JSON string
        return JSON.serialize(jsonMap);
    }
    
    private static Map<String, Object> cleanJsonMap(Map<String, Object> jsonMap) {
        Map<String, Object> cleanedMap = new Map<String, Object>();
        
        for (String key : jsonMap.keySet()) {
            Object value = jsonMap.get(key);
            if (value instanceof Map<String, Object>) {
                value = cleanJsonMap((Map<String, Object>) value);
            } else if (value instanceof List<Object>) {
                value = cleanJsonList((List<Object>) value);
            }
            
            if (value != null) {
                cleanedMap.put(key, value);
            }
        }
        
        return cleanedMap;
    }
    
    private static List<Object> cleanJsonList(List<Object> jsonList) {
        List<Object> cleanedList = new List<Object>();
        
        for (Object item : jsonList) {
            if (item instanceof Map<String, Object>) {
                item = cleanJsonMap((Map<String, Object>) item);
            } else if (item instanceof List<Object>) {
                item = cleanJsonList((List<Object>) item);
            }
            
            if (item != null) {
                cleanedList.add(item);
            }
        }
        
        return cleanedList;
    }
}