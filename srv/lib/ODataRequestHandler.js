class ODataRequestHandler {
    
    // ========================== $filter =============================== //
    // Aribaの Operational Reporting API においてデフォルトのクエリパラメータとして提供されている日付に関するクエリの抽出のみ扱う
    // Ariba側でデータの絞り込みが走る
    parseFilter_ariba(select) {
        const tmp_dateRange = {};
        const filter = {};
        Object.assign(
            filter,
            this.#parseExpression(select.where)
        );
        let params = {
            /*
            appid: apiKey,
            */
        };
        for (const key of Object.keys(filter)) {
            switch (key) {
                case "filters":
                    // params["filters"] = filter[key];
                    break;
                case "createdDateFrom":
                    tmp_dateRange["createdDateFrom"] = filter[key];
                    break;
                case "createdDateTo":
                    tmp_dateRange["createdDateTo"] = filter[key];
                    break;
                case "ApprovedState":
                    break;
                case "Name":
                    break;
                default:
                    throw new Error(`Filter by '${key}' is not supported.`);
            }
        }
        let filtersString = null;
        if (Object.keys(tmp_dateRange).length == 0) {
            // 初回ロード時はDateがないので、初期値を入れる。
            filtersString = `{"createdDateFrom":"2023-07-30T00:00:00Z","createdDateTo":"2023-08-30T00:00:00Z"}`
        } else {
            filtersString = `{"createdDateFrom":"${tmp_dateRange.createdDateFrom}","createdDateTo":"${tmp_dateRange.createdDateTo}"}`
        }
        params = Object.assign(params, { filters: filtersString })
        return params;
    }
    
    // Ariba の API のクエリパラメータ以外のクエリ抽出を行う
    // CAP 側でデータの絞り込みを行う
    parseFilter_custom(select) {
        const filter = {};
        Object.assign(
            filter,
            this.#parseExpression(select.where)
        );
        const params = {
            /*
            appid: apiKey,
            */
        };
        for (const key of Object.keys(filter)) {
            switch (key) {
                case "ApprovedState":
                    params["ApprovedState"] = filter[key];
                    break;
                case "Name":
                    params["InitialUniqueName"] = filter[key];
                    break;
                case "filters":
                    break;
                case "createdDateFrom":
                    break;
                case "createdDateTo":
                    break;
                default:
                    throw new Error(`[ERROR] Filter by '${key}' is not supported.(custom)`);
            }
        }
        return params;
    }
    
    #parseExpression(expr) {
        if (!expr) {
            return {};
        }
        const parsed = {};
    
        for (let i = 0; i < expr.length; i = i + 4) {
            const and_expr = expr.slice(i, i + 3);
            const [property, operator, value] = and_expr;
            if (operator !== "=") {
                throw new Error(`Expression with '${operator}' is not allowed.`);
            }
            if (property && value) {
                parsed[property.ref[0]] = value.val;
            }
        }
        return parsed;
    }

    // ========================== $orderby =============================== //
    // in: InitialUniqueName desc // InitialUniqueName
    // out: ["InitialUniqueName", "desc"] // ["InitialUniqueName", "asc"]
    parseOrderby(orderby) {
        // スペースで分割して配列にする
        const parts = orderby.split(/\s+/);
        // 列名を取得
        const columnName = parts[0];
        // ソート順を取得（デフォルトは "asc"）
        const sortOrder = parts.length > 1 ? parts[1].toLowerCase() : "asc";
        // ソート順が "asc" か "desc" 以外の場合、デフォルトの "asc" を使用
        if (sortOrder !== "asc" && sortOrder !== "desc") {
            return [columnName, "asc"];
        }
        // 結果を返す
        return [columnName, sortOrder];
    }
}

module.exports = ODataRequestHandler;