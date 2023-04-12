public class ACAMSCeregoDTO {

    public List<Data> data { get; set; }
    public Links links { get; set; }
    public Meta meta { get; set; }

    public ACAMSCeregoDTO(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'data') {
                        data = arrayOfData(parser);
                    } else if (text == 'links') {
                        links = new Links(parser);
                    } else if (text == 'meta') {
                        meta = new Meta(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'ACAMSCeregoDTO consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Meta {
        public Integer totalPages { get; set; }
        public Integer totalCount { get; set; }

        public Meta(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'total-pages') {
                            totalPages = parser.getIntegerValue();
                        } else if (text == 'total-count') {
                            totalCount = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Meta consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Attributes {
        public String token { get; set; }
        public String expiresAt { get; set; }
        public Integer expiresIn { get; set; }

        public Attributes(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'token') {
                            token = parser.getText();
                        } else if (text == 'expires-at') {
                            expiresAt = parser.getText();
                        } else if (text == 'expires-in') {
                            expiresIn = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Links {

        public Links(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            System.debug(LoggingLevel.WARN, 'Links consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Data {
        public String id { get; set; }
        public String type_Z { get; set; } // in json: type
        public Attributes attributes { get; set; }

        public Data(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'attributes') {
                            attributes = new Attributes(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }


    public static ACAMSCeregoDTO parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ACAMSCeregoDTO(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                    curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }


    private static List<Data> arrayOfData(System.JSONParser p) {
        List<Data> res = new List<Data>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Data(p));
        }
        return res;
    }


}