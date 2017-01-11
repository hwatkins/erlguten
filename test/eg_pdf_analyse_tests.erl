-module(eg_pdf_analyse_tests).

-include_lib("eunit/include/eunit.hrl").

-define(PDF_DIR, "../test/pdf/").

page_count_one_test() ->
    PDF = eg_pdf_analyse:open(?PDF_DIR ++ "Stallman_Ebooks.pdf"),
    ?assertEqual(1, eg_pdf_analyse:get_page_count(PDF)),
    eg_pdf_analyse:close(PDF).

%% This tests the page count of a PDF with a page tree with nested page tree
%% nodes to make sure we retrieve the page count from the root page tree node.
page_count_nested_test() ->
    PDF = eg_pdf_analyse:open(
            ?PDF_DIR ++ "OReilly_UnderstandingOSFSLicensing_Ch2.pdf"),
    ?assertEqual(20, eg_pdf_analyse:get_page_count(PDF)),
    eg_pdf_analyse:close(PDF).

%% Eat your own dogfood.
page_count_dogfood_test() ->
    %% Make a PDF for _analyse_ to play with
    save_basic_pdf("dogfood.pdf"),

    %% Get pagecount of our own PDF
    PDF = eg_pdf_analyse:open("dogfood.pdf"),
    ?assertEqual(2, eg_pdf_analyse:get_page_count(PDF)),
    eg_pdf_analyse:close(PDF).

page_count_ram_mode_test() ->
    save_basic_pdf("dogfood.pdf"),
    {ok, Data} = file:read_file("dogfood.pdf"),
    PDF = eg_pdf_analyse:open(Data, [ram]),
    ?assertEqual(2, eg_pdf_analyse:get_page_count(PDF)),
    eg_pdf_analyse:close(PDF).


save_basic_pdf(Filename) ->
    EgPDF = eg_pdf:new(),
    eg_pdf:set_pagesize(EgPDF,letter),
    eg_pdf:set_page(EgPDF,1),
    eg_pdf:begin_text(EgPDF),
    eg_pdf:set_font(EgPDF, "Times-Roman", 24),
    eg_pdf:set_text_pos(EgPDF, 60,600),
    eg_pdf:text(EgPDF, "Hello  "),
    eg_pdf:end_text(EgPDF),
    eg_pdf:new_page(EgPDF),
    eg_pdf:begin_text(EgPDF),
    eg_pdf:set_font(EgPDF, "Times-Roman", 24),
    eg_pdf:set_text_pos(EgPDF, 60,600),
    eg_pdf:text(EgPDF, "World!"),
    eg_pdf:end_text(EgPDF),
    eg_pdf:save_state(EgPDF),
    {Serialised, _PageNo} = eg_pdf:export(EgPDF),
    ok = file:write_file(Filename, [Serialised]),
    eg_pdf:delete(EgPDF).
