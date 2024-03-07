class ODataResponseHandler {
	filterByCustomQuery(response, customQuery) {
		const response_filtered = response.filter(record => {
			const q = customQuery;
			return Object.keys(q).every(key => {
				// console.log(`    [INFO] : ${record.InitialUniqueName} に対し、カスタムクエリ (${key} = ${q[key]}) でフィルタリング => ${record[key] == q[key]}`);
				return record[key] == q[key];
			});
		});
		return response_filtered;
	}

	orderby(response, orderby) {
		// orderby配列から列名とソート順を取得
		const [columnName, sortOrder] = orderby;
		// 比較
		const compare = (a, b) => {
			// 値を取得
			let valueA = a[columnName];
			let valueB = b[columnName];
			// 文字列、datetime、数字の比較を適切に行う
			if (typeof valueA === 'string') {
				valueA = valueA.toLowerCase();
				valueB = valueB.toLowerCase();
			}
			if (valueA < valueB) {
				return sortOrder === 'asc' ? -1 : 1;
			}
			if (valueA > valueB) {
				return sortOrder === 'asc' ? 1 : -1;
			}
			return 0;
		};
		// 配列をソートして返す
		return response.sort(compare);
	}

	addParentLink(target, key) {
		target.forEach(record => {
			if(record[key] != null) {
				record[key].forEach(childRecord => {
					childRecord["parent"] = record.InitialUniqueName
					// console.log(`    [INFO] : ${key} のレコード ${childRecord.parent} に対し、parent ${record.InitialUniqueName} を紐づけました`)
				})
			}
		})
		return target;
	}

	set$count(target) {
		target.$count = target.length;
		return target;
	}
}

module.exports = ODataResponseHandler;