require 'test_helper'

class PlayerPointTotalsControllerTest < ActionController::TestCase
  setup do
    @player_point_total = player_point_totals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:player_point_totals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create player_point_total" do
    assert_difference('PlayerPointTotal.count') do
      post :create, player_point_total: {  }
    end

    assert_redirected_to player_point_total_path(assigns(:player_point_total))
  end

  test "should show player_point_total" do
    get :show, id: @player_point_total
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @player_point_total
    assert_response :success
  end

  test "should update player_point_total" do
    patch :update, id: @player_point_total, player_point_total: {  }
    assert_redirected_to player_point_total_path(assigns(:player_point_total))
  end

  test "should destroy player_point_total" do
    assert_difference('PlayerPointTotal.count', -1) do
      delete :destroy, id: @player_point_total
    end

    assert_redirected_to player_point_totals_path
  end
end
