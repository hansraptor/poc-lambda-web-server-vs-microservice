
function parseQueryStringIntoObject(queryString) {
  // queryString = queryString.trim();
  queryString = queryString
    .replace(/^ +/, "")
    .replace(/ +$/, "");

  let query = {};

  if (queryString === "") {
    return query;
  }

  try {
    // Try to parse query
    query = queryString
      .replace(/^\?+/, "")
      .replace(/\?+$/, "")
      .split("&")
      .reduce((accumulator, paramKeyValueString) => {
        let keyValueList = paramKeyValueString.split("=");
        let key = keyValueList[0].trim();
        let value = (keyValueList[1] || "").trim();

        accumulator[key] = value;

        return accumulator;
      }, query);
  }
  catch (queryParseError) {
    query["error"] = queryParseError;
  }

  return query;
}

module.exports = {
  parseQueryString: parseQueryStringIntoObject
};
