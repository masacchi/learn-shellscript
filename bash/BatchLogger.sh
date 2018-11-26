#!/bin/bash

APPLICATION_LOGFILE=/temp/log/application.log
SYSERROR_LOGFILE=/temp/log/error.log

function writeLog () {
    # ----- オプション解析 -----
    local OPTIND="" OPTARG="" STDOUT_OPTION="" # globalにしておくと複数回実行できない
    getopts ":e" STDOUT_OPTION
    case ${STDOUT_OPTION} in
        e)
            # ----- 引数から削除 -----
            shift $((OPTIND - 1))
            ;;
        \?)
            if [[ "" != ${OPTARG} ]]; then
                # 想定していないオプションの場合、何もしない
                echo "何もしない 想定外オプション: ${OPTARG}"
                return 1;
            fi

    esac

    # ----- 引数チェック -----
    if [[ "INFO" != $1 ]] && [[ "WARN" != $1 ]] && [[ "ERROR" != $1 ]]; then
        echo "何もしない 不正なログレベル: $1"
        return 1;
    fi

    # いろいろ引数チェックして

    # 出力ログファイル判定
    local LOGFILE
    if [[ "INFO" != $1 ]] || [[ "WARN" = $1 ]]; then
        LOGFILE=APPLICATION_LOGFILE
    elif [[ "ERROR" = $1 ]]; then
        LOGFILE=SYSERROR_LOGFILE
    fi

    # ログ出力項目
    local date="$(date --iso-8601=ns | sed -rn 's/(^.*,.{3}).*(\+.*$)/\1\2/p')"
    local host="$(hostname)"
    local layer="$(basename $0)"

    local logTxt="${date}\t${1}\t${host}\t${layer}\t${2}\t${3}\t${4}"
    
    if [[ "e" = ${STDOUT_OPTION} ]]; then
        echo -e ${logTxt} | tee -a ${LOGFILE}
    else
        echo -e ${logTxt} >> ${LOGFILE}
    fi
}


# サンプル

#-e オプション
writeLog -e "INFO" "execId" "messageId" "-e オプション$(hostname)"
# 想定外オプション -z
writeLog -z "INFO" "execId" "messageId" "想定外オプション -z$(hostname)"
# オプションなし
writeLog "INFO" "execId" "messageId" "オプションなし$(hostname)"


# WARNログ
writeLog -e "WARN" "execId" "messageId" "メッセージ本文$(hostname)"
# ERRORログ
writeLog -e "ERROR" "execId" "messageId" "メッセージ本文$(hostname)"
# 想定外ログレベル
writeLog -e "TRACE" "execId" "messageId" "メッセージ本文$(hostname)"