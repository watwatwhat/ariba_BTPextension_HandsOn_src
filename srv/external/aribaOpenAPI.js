const cds = require("@sap/cds");

const ODataRequestHandlerClass = require('../lib/ODataRequestHandler');
const ODataRequestHandler = new ODataRequestHandlerClass();

class aribaOpenAPI extends cds.RemoteService {

  async init() {
    // GET以外のリクエストは排除する
    this.reject(["CREATE", "UPDATE", "DELETE"], "*");

    // 準備：AribaのAPIからデータを取得するためのトークンを取得する
    this.before("READ", "*", async (req) => {

      try {
        // ================== Query Parameters Parsing ================== //
        const queryParams = ODataRequestHandler.parseFilter_ariba(req.query.SELECT);
        const queryString = Object.keys(queryParams)
          .map((key) => `&${key}=${queryParams[key]}`)

        // ================== Credential Settings ================== //
        let viewTemplateName = "";
        console.log(`    [INFO] 呼び出し中のCAPサービス : ${req.target.name}`);
        switch (req.target.name) {
          case "my.ariba.C_Requisitions":
            viewTemplateName = "Requisition_SAP_createdRange_v2";
            break;
          case "my.ariba.C_Requisitions__to_ApprovalRecords":
            viewTemplateName = "Requisition_SAP_createdRange_v2";
            break;
          case "my.ariba.C_Requisitions__to_LineItems":
            viewTemplateName = "Requisition_SAP_createdRange_v2";
            break;
          case "my.ariba.C_Invoices":
            viewTemplateName = "Invoice_SAP_createdRange_v2";
            break;
          default:
            req.reject(403, `Access to ${req.target.projection.from.ref[0]} Not Allowed.`);
        };
        const realm = cds.env.realm;
        const Base64Encoded_OAuth_client_id_and_secret = cds.env.Base64Encoded_OAuth_client_id_and_secret;
        const apiKey = cds.env.ApplicationKey;

        // ================== Fetching Token ================== //
        const aribaOAuthServer = await cds.connect.to("aribaOAuthServer");
        const response_oauth = await aribaOAuthServer.send({
          "method": "POST",
          "headers": {
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": `Basic ${Base64Encoded_OAuth_client_id_and_secret}`
          },
          "path": "/"
        })
        const access_token = response_oauth.access_token;
        console.log(`    [INFO] API アクセストークンを取得しました : ${access_token}`);
        req.headers["apiKey"] = apiKey;
        req.headers["Authorization"] = `Bearer ${access_token}`;
        req.headers["Content-Type"] = `application/x-www-form-urlencoded`;
        req.headers["Accept"] = `application/json`;

        req.query = `GET /views/${viewTemplateName}?realm=${realm}`;
        if (Object.keys(queryString).length > 0) {
          req.query = req.query + queryString;
        }
      } catch (error) {
        req.reject(error.statusCode, error.message);
      }
    });

    // AribaのAPIからデータを取得してカスタムハンドラに返す
    this.on("READ", "*", async (req, next) => {
      let response = null
      try {
        response = await next(req);
      } catch (err) {
        throw new Error(err);
      }

      // ========================== 以下 FreeStyle 向けカスタムコード ========================

      // . -> _ に変換する
      // function replaceDotsWithUnderscores(obj) {
      //   if (obj === null || obj === undefined) {
      //     return; // nullまたはundefinedの場合、何もしない
      //   }
      //   if (Array.isArray(obj)) {
      //     obj.forEach(item => replaceDotsWithUnderscores(item));
      //   } else if (typeof obj === 'object') {
      //     Object.keys(obj).forEach(key => {
      //       const newKey = key.replace(/\./g, '_');
      //       if (newKey !== key) {
      //         obj[newKey] = obj[key];
      //         delete obj[key];
      //       }
      //       replaceDotsWithUnderscores(obj[newKey]);
      //     });
      //   }
      // }
      // function replaceDotsWithUnderscores(obj, parentKey = '') {
      //   if (obj === null || obj === undefined) {
      //     return; // nullまたはundefinedの場合、何もしない
      //   }
      //   if (Array.isArray(obj)) {
      //     obj.forEach(item => replaceDotsWithUnderscores(item, parentKey));
      //   } else if (typeof obj === 'object') {
      //     Object.keys(obj).forEach(key => {
      //       const newKey = key.replace(/\./g, '_');
      //       if (newKey !== key) {
      //         obj[newKey] = obj[key];
      //         delete obj[key];
      //       }

      //       // LineItems 内の Supplier オブジェクトを特別に処理
      //       if (parentKey === 'LineItems' && newKey === 'Supplier') {
      //         if (obj[newKey] && obj[newKey].Name) {
      //           obj[newKey] = `${obj[newKey].Name}`;
      //         } else {
      //           obj[newKey] = null; // Supplierがnullの場合、nullを保持
      //         }
      //       } else {
      //         replaceDotsWithUnderscores(obj[newKey], newKey);
      //       }
      //     });
      //   }
      // }
      function replaceDotsWithUnderscores(obj, parentKey = '') {
        if (obj === null || obj === undefined) {
          return; // nullまたはundefinedの場合、何もしない
        }
        if (Array.isArray(obj)) {
          obj.forEach(item => replaceDotsWithUnderscores(item, parentKey));
        } else if (typeof obj === 'object') {
          Object.keys(obj).forEach(key => {
            const newKey = key.replace(/\./g, '_');
            if (newKey !== key) {
              obj[newKey] = obj[key];
              delete obj[key];
            }

            // LineItems 内の Supplier オブジェクトを特別に処理
            if (parentKey === 'LineItems' && newKey === 'Supplier') {
              if (obj[newKey] && obj[newKey].Name) {
                obj[newKey] = `${obj[newKey].Name}`;
              } else {
                obj[newKey] = null; // Supplierがnullの場合、nullを保持
              }
            }

            // LineItems 内の Description_UnitOfMeasure を SplitAccountings に移動
            if (parentKey === 'LineItems' && newKey === 'Description_UnitOfMeasure' && obj.SplitAccountings) {
              obj.SplitAccountings.forEach(splitAccounting => {
                splitAccounting['Description_UnitOfMeasure'] = obj[newKey];
              });
              delete obj[newKey];
            }

            replaceDotsWithUnderscores(obj[newKey], parentKey ? `${parentKey}_${newKey}` : newKey);
          });
        }
      }
      replaceDotsWithUnderscores(response.Records);

      return response.Records;
    });

    super.init();
  }
}

module.exports = aribaOpenAPI;