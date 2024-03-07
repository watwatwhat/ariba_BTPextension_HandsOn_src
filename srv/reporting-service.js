const cds = require('@sap/cds');

const ODataRequestHandlerClass = require('./lib/ODataRequestHandler');
const ODataRequestHandler = new ODataRequestHandlerClass();

const ODataResponseHandlerClass = require('./lib/ODataResponseHandler');
const ODataResponseHandler = new ODataResponseHandlerClass();

const { console_log_color, getCorrelationID } = require('./lib/designTimeTools');

module.exports = cds.service.impl(async function (srv) {

  // Aribaからのレスポンスを一時的にcacheとして保存する
  let cacheData = null;

  // DateRangeに関しては一時的に保存しておく
  // (DateRangeが変わるとキャッシュが意味をなさなくなるため、再度データをとってくる必要がある)
  let lastDateRange = null;

  console_log_color(`    [INFO] バックエンドキャッシュの状態を初期化しました`, "red");

  /*** SERVICE HANDLERS ***/
  this.on('READ', '*', async (req) => {

    const corrID = getCorrelationID();
    console_log_color(`    [INFO: ${corrID}] サービス: ${req.target.name} を読み込んでいます`, "red");

    // Objectページの場合は、qにUniqueNameを入れる
    let q = null;
    if (req.query.SELECT.from.ref[0].where) {
      q = req.query.SELECT.from.ref[0].where[2].val;
    }
    console_log_color(`    [INFO: ${corrID}] Query Options: ${JSON.stringify(req._queryOptions)}`, "blue");

    // QueryOptionsを抽出する
    const dateRange = ODataRequestHandler.parseFilter_ariba(req.query.SELECT).filters;
    const qo_custom = ODataRequestHandler.parseFilter_custom(req.query.SELECT);
    let qo_orderby = null
      // req._queryOptionsが存在し、かつ$orderbyプロパティがあるかを確認
    if(req._queryOptions && req._queryOptions.$orderby) {
      console_log_color(`    [INFO: ${corrID}] orderbyクエリが検知されました: ${JSON.stringify(req._queryOptions.$orderby)}`, "blue");
      qo_orderby = ODataRequestHandler.parseOrderby(req._queryOptions.$orderby);
    }
    console_log_color(`    [INFO: ${corrID}] 指定された時間範囲: ${dateRange}`, "blue");
    console_log_color(`    [INFO: ${corrID}] 指定されたカスタムクエリ: ${JSON.stringify(qo_custom)}`, "blue");

    // キャッシュがある AND ( リストページでDateRangeが変わっていない OR オブジェクトページ)
    if (cacheData && ((lastDateRange == dateRange) || q)) {
      console_log_color(`    [INFO: ${corrID}] 有効なキャッシュが検知されました キャッシュからデータを出力します`, "red");
      console_log_color(`    [INFO: ${corrID}] キャッシュの先頭: ${cacheData[0].UniqueName}`, "red");

      let response_main = null;
      let response_to_ApprovalRecords = null;
      let response_to_LineItems = null;

      switch (req.target.name) {
        case "ReportingService.C_Requisitions":
          // C_Requisitionsが呼び出された場合
          if (q) {
            // C_Requisitions('q'): qが存在する場合、すなわちObjectページの場合
            // 対象のデータに絞ってヘッダデータを返す
            response_main = cacheData.filter(item => {
              return item.UniqueName == q
            })

            if (response_main) {
              response_main.$count = response_main.length;
            }
            return response_main;
          } else {
            // qが存在しない場合、すなわちListページの場合
            // qo_customによるフィルタリングをした上で、ヘッダデータを返す
            // その他のクエリオプションもある場合は処理する
            let response_final = ODataResponseHandler.filterByCustomQuery(cacheData, qo_custom);
            if(qo_orderby) {
              response_final = ODataResponseHandler.orderby(response_final, qo_orderby);
            }
            ODataResponseHandler.set$count(response_final);
            return response_final;
          }
        case "ReportingService.C_Requisitions__to_ApprovalRecords":
          // C_Requisitions__to_ApprovalRecordsが呼び出された場合
          if (q) {
            // qが存在する場合、すなわちObjectページの場合
            // 対象のデータに絞って明細データを返す
            cacheData.forEach((el => {
              if (el.UniqueName == q) {
                response_to_ApprovalRecords = el.ApprovalRecords;
              }
            }))
            if (response_to_ApprovalRecords) {
              response_to_ApprovalRecords.$count = response_to_ApprovalRecords.length;
            }
            return response_to_ApprovalRecords;
          } else {
            // qが存在しない場合、すなわちListページの場合
            // 全ての明細データを返す
            response_to_ApprovalRecords = [];
            cacheData.forEach((el) => {
              if (el.ApprovalRecords) {
                console.log(el.ApprovalRecords);
                el.ApprovalRecords.forEach(apRecord => {
                  response_to_ApprovalRecords.push(apRecord);
                })
              }
            })
            console.log(response_to_ApprovalRecords);
            response_to_ApprovalRecords.$count = response_to_ApprovalRecords.length;
            return response_to_ApprovalRecords;
          }
        case "ReportingService.C_Requisitions__to_LineItems":
          // C_Requisitions__to_LineItemsが呼び出された場合
          if (q) {
            // qが存在する場合、すなわちObjectページの場合
            // 対象のデータに絞って明細データを返す
            cacheData.forEach((el => {
              if (el.UniqueName == q) {
                response_to_LineItems = el.LineItems;
              }
            }))
            if (response_to_LineItems) {
              response_to_LineItems.$count = response_to_LineItems.length;
            }
            return response_to_LineItems;
          } else {
            // qが存在しない場合、すなわちListページの場合
            // 全ての明細データを返す
            response_to_LineItems = [];
            cacheData.forEach((el) => {
              if (el.LineItems) {
                console.log(el.LineItems);
                el.LineItems.forEach(apRecord => {
                  response_to_LineItems.push(apRecord);
                })
              }
            })
            console.log(response_to_LineItems);
            response_to_LineItems.$count = response_to_LineItems.length;
            return response_to_LineItems;
          }
      }
    } else {
      // キャッシュがない OR (リストページでDateRangeが変わっている)
      !cacheData ? console_log_color(`    [Warning:${corrID}] キャッシュが存在しません 新規データを取得します`, "red") : console_log_color(`    [Warning:${corrID}] 日付のクエリ範囲が変更されました 新規データを取得します`, "red");

      // 今の日付クエリ条件を保存しておく
      const qo_default = ODataRequestHandler.parseFilter_ariba(req.query.SELECT);
      lastDateRange = qo_default.filters;

      let response_main = null;
      let response_to_ApprovalRecords = null;
      let response_to_LineItems = null;

      // 一旦 ヘッダ / 明細データ を取得してcacheDataに格納する
      const aribaOpenAPI = await cds.connect.to("aribaOpenAPI_OperationalReportingForProcurement");
      cacheData = await aribaOpenAPI.tx(req).run(req.query);

      console_log_color(`    [INFO: ${corrID}] キャッシュの先頭: ${cacheData[0].UniqueName}`, "red");

      switch (req.target.name) {
        case "ReportingService.C_Requisitions":
          // C_Requisitionsが呼び出された場合
          if (q) {
            // qが存在する場合、すなわちObjectページの場合
            // 対象のデータに絞ってヘッダデータを返す
            cacheData.forEach((el => {
              console.log(el.UniqueName);
              if (el.UniqueName == q) {
                response_main = el;
              }
            }))
            if (response_main) {
              response_main.$count = response_main.length;
            }
            console.log("response_main: ", response_main);
            return response_main;
          } else {
            // qが存在しない場合、すなわちListページの場合
            // 全てのヘッダデータを返す
            cacheData.$count = cacheData.length;
            return cacheData;
          }
        case "ReportingService.C_Requisitions__to_ApprovalRecords":
          // C_Requisitions__to_ApprovalRecordsが呼び出された場合
          if (q) {
            // qが存在する場合、すなわちObjectページの場合
            // 対象のデータに絞って明細データを返す
            cacheData.forEach((el => {
              if (el.UniqueName == q) {
                response_to_ApprovalRecords = el.ApprovalRecords;
              }
            }))
            if (response_to_ApprovalRecords) {
              response_to_ApprovalRecords.$count = response_to_ApprovalRecords.length;
            }
            return response_to_ApprovalRecords;
          } else {
            // qが存在しない場合、すなわちListページの場合
            // 全ての明細データを返す
            response_to_ApprovalRecords = [];
            cacheData.forEach((el) => {
              if (el.ApprovalRecords) {
                console.log(el.ApprovalRecords);
                el.ApprovalRecords.forEach(apRecord => {
                  response_to_ApprovalRecords.push(apRecord);
                })
              }
            })
            console.log(response_to_ApprovalRecords);
            response_to_ApprovalRecords.$count = response_to_ApprovalRecords.length;
            return response_to_ApprovalRecords;
          }
        case "ReportingService.C_Requisitions__to_LineItems":
          // C_Requisitions__to_LineItemsが呼び出された場合
          if (q) {
            // qが存在する場合、すなわちObjectページの場合
            // 対象のデータに絞って明細データを返す
            cacheData.forEach((el => {
              if (el.UniqueName == q) {
                response_to_LineItems = el.LineItems;
              }
            }))
            if (response_to_LineItems) {
              response_to_LineItems.$count = response_to_LineItems.length;
            }
            return response_to_LineItems;
          } else {
            // qが存在しない場合、すなわちListページの場合
            // 全ての明細データを返す
            response_to_LineItems = [];
            cacheData.forEach((el) => {
              if (el.LineItems) {
                console.log(el.LineItems);
                el.LineItems.forEach(apRecord => {
                  response_to_LineItems.push(apRecord);
                })
              }
            })
            console.log(response_to_LineItems);
            response_to_LineItems.$count = response_to_LineItems.length;
            return response_to_LineItems;
          }
      }
    }
  });
});