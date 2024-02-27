export function exportCSVFile(headers, totalData, fileTitle){
    if(!totalData || !totalData.length){
        return null;
    }
    const jsonObject = JSON.stringify(totalData);
    const result = convertToCSV(jsonObject, headers);
    //if(result === null) return
    //const blob = new Blob([result])
    const exportedFilename = fileTitle ? fileTitle + '.csv' : 'export.csv';
    const link = window.document.createElement('a');
    link.href = 'data:text/csv;charset=utf-8,' + encodeURI(result);
    link.target = "_blank";
    link.download = exportedFilename;
    document.body.appendChild(link);
    link.click();
}
function convertToCSV(objArray, headers){
    const columnDelimiter = ',';
    const lineDelimiter = '\r\n';
    const actualHeaderKey = Object.keys(headers);
    const headerToShow = Object.values(headers) ;
    let str = '';
    str+=headerToShow.join(columnDelimiter) ;
    str+=lineDelimiter;
    const data = typeof objArray !=='object' ? JSON.parse(objArray):objArray;
    data.forEach(obj=>{
        let line = '';
        actualHeaderKey.forEach(key=>{
            if(line !=''){
                line+=columnDelimiter;
            }
            //let strItem = obj[key]+'';
            let strItem = (obj[key] === undefined || obj[key] === null) ? ' ': obj[key]+'';
            line += strItem? strItem.replace(/,/g, ''):strItem;
        })
        str+=line+lineDelimiter;
        console.log('STRRR' + str);
    })
    return str;
}

export function getCSVLine(line) {
    if (line.startsWith(','))
        line = line.replace(',', ':blank:,');
    while (line.includes(',,')) {
        line = line.replace(',,', ',:blank:,');
    }
    if (line.endsWith(','))
        line = line + ':blank:';
    var arr = line.match(/(?:\"([^\"]*(?:\"\"[^\"]*)*)\")|([^\",]+)/g);
    return arr;
}