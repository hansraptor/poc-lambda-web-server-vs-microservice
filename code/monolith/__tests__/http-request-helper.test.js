
const httpRequestHelper = require("../functions/http-request-helper");

describe("parse request query string into JSON object", () => {
    let testCases = [
        { input: "", expected: {} },
        { input: "      ", expected: {} },
        { input: "no=questionmark", expected: { no: "questionmark" } },
        { input: "novalue=", expected: { novalue: "" } },
        { input: " ?delicious=cheese ", expected: { delicious: "cheese" } },
        { input: " ?delicious=  cheese ", expected: { delicious: "cheese" } },
        { input: " ?     delicious    =  cheese ", expected: { delicious: "cheese" } },
        { input: "?delicious=cheese&scrumptuous=bacon", expected: { delicious: "cheese", scrumptuous: "bacon" } },
        { input: "?delicious=cheese&scrumptuous=bacon&fluffy=donut", expected: { delicious: "cheese", scrumptuous: "bacon", fluffy: "donut" } }
    ]

    for (let index = 0; index < testCases.length; index++) {
        let testCase = testCases[index];
        let input = testCase.input;
        let expected = testCase.expected;
        let actual = httpRequestHelper.parseQueryString(input);

        it(`input of [${input}] should return object ${ expected }`, () => {
            expect(actual).toMatchObject(expected);
        });
    }
});
