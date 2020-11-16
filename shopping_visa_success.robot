*** Settings ****
Library    SeleniumLibrary
Library    Collections
Library    RequestsLibrary
Suite Setup    Create Session    alias=shopping    url= http://www.dminer.in.th


*** Variables ***
&{headers}     Content-Type=application/json    Accept=application/json

*** Test Cases ***
user ซื้อของเล่นให้ลูกสาว เลือกวิธีการจัดส่งผ่าน kerry การชำระเงินด้วยบัตรเครดิตด้วย visa และชำระเงินสำเร็จ
    Search
    Product Detail    2
    Submit Order
    Confirm Payment

*** Keywords ***
Search
    ${resp}=    Get Request    alias=shopping    uri=/api/v1/product
    Request Should Be Successful    ${resp}
    Should Be Equal As Integers    ${resp.json()['total']}    2
    Should Be Equal    ${resp.json()['products'][1]['product_name']}    43 Piece dinner Set
    Should Be Equal    ${resp.json()['products'][1]['product_image']}    /43_Piece_dinner_Set.png
    Should Be Equal As Numbers    ${resp.json()['products'][1]['product_price']}    12.95

Product Detail
    [Arguments]    ${product_id}
    ${resp}=    Get Request    alias=shopping    uri=/api/v1/product/${product_id}   headers=&{headers}
    Request Should Be Successful    ${resp}
    Should Be Equal As Integers    ${resp.json()['id']}    2
    Should Be Equal    ${resp.json()['product_name']}    43 Piece dinner Set
    Should Be Equal As Numbers    ${resp.json()['product_price']}    12.95
    Should Be Equal As Integers    ${resp.json()['quantity']}    10
    Should Be Equal    ${resp.json()['product_brand']}    CoolKidz
    Should Be Equal    ${resp.json()['product_image']}    /43_Piece_dinner_Set.png

Submit Order
    ${data}=    To Json    { "cart" : [ { "product_id": 2, "quantity": 1 } ], "shipping_method" : "Kerry", "shipping_address" : "405/37 ถ.มหิดล", "shipping_sub_district" : "ต.ท่าศาลา", "shipping_district" : "อ.เมือง", "shipping_province" : "จ.เชียงใหม่", "shipping_zip_code" : "50000", "recipient_name" : "ณัฐญา ชุติบุตร", "recipient_phone_number" : "0970809292" }
    ${resp}=    Post Request    alias=shopping    uri=/api/v1/order    headers=&{headers}    json=${data}
    Request Should Be Successful    ${resp}
    Should Be Equal As Integers    ${resp.json()['order_id']}    8004359122
    Should Be Equal As Numbers    ${resp.json()['total_price']}    14.95
    ${order_id}=    Set Variable    ${resp.json()['order_id']}
    ${total_price}=    Set Variable    ${resp.json()['total_price']}
    Set Global Variable    ${order_id}
    Set Global Variable    ${total_price}


Confirm Payment
    ${body}=    To Json    {"order_id": ${order_id}, "payment_type": "credit","type": "visa","card_number": "4719700591590995","cvv": "752","expired_month": 7,"expired_year": 20,"card_name": "Karnwat Wongudom","total_price": ${total_price}}
    ${resp}=    Post Request    alias=shopping    uri=/api/v1/confirmPayment    headers=&{headers}    json=${body}
    Request Should Be Successful    ${resp}
    Should Be Equal As Strings    ${resp.json()["notify_message"]}    วันเวลาที่ชำระเงิน 1/3/2020 13:30:00 หมายเลขคำสั่งซื้อ ${order_id} คุณสามารถติดตามสินค้าผ่านช่องทาง Kerry หมายเลข 1785261900